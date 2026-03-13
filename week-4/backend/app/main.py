import os
import time
import threading
import signal
import requests
import boto3
import psycopg2
import json
from flask import Flask, request, jsonify

app = Flask(__name__)

# --- SRE Graceful Shutdown Logic ---
class GracefulKiller:
    def __init__(self):
        signal.signal(signal.SIGINT, self.exit_gracefully)
        signal.signal(signal.SIGTERM, self.exit_gracefully)
    def exit_gracefully(self, signum, frame):
        print(f"Process exiting on signal {signum}...")
        os._exit(0)

killer = GracefulKiller()

# --- Token Bucket Rate Limiter ---
class TokenBucket:
    def __init__(self, capacity, fill_rate):
        self.capacity = float(capacity)
        self.tokens = float(capacity)
        self.fill_rate = float(fill_rate)  # tokens per second
        self.last_refill = time.time()
        self.lock = threading.Lock()

    def wait_for_tokens(self, tokens=1):
        with self.lock:
            now = time.time()
            elapsed = now - self.last_refill
            self.tokens = min(self.capacity, self.tokens + (elapsed * self.fill_rate))
            self.last_refill = now
            
            if self.tokens >= tokens:
                self.tokens -= tokens
                return 0
            return (tokens - self.tokens) / self.fill_rate

# --- IAM Database Helper ---
def get_db_connection():
    host = os.environ.get('DB_HOST')
    user = os.environ.get('DB_USER', 'dbadmin')
    region = os.environ.get('AWS_REGION', 'ap-south-1')
    
    # IAM Auth Token (No passwords stored in code)
    rds_client = boto3.client('rds', region_name=region)
    token = rds_client.generate_db_auth_token(
        DBHostname=host, Port=5432, DBUsername=user, Region=region
    )
    
    return psycopg2.connect(
        host=host, 
        port=5432, 
        database='pollingdb', 
        user=user, 
        password=token,
        sslmode='require'
    )

# --- Database Schema Setup ---
def init_db():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            CREATE TABLE IF NOT EXISTS api_logs (
                id SERIAL PRIMARY KEY,
                data TEXT,
                status_code INTEGER,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        conn.commit()
        cur.close()
        conn.close()
        print("Database initialized successfully.")
    except Exception as e:
        print(f"Database initialization failed: {e}")

# --- CloudWatch Helper ---
def put_metric(metric_name, value):
    try:
        cw_client = boto3.client('cloudwatch', region_name=os.environ.get('AWS_REGION', 'ap-south-1'))
        cw_client.put_metric_data(
            Namespace='XLDP/PollingApp',
            MetricData=[{'MetricName': metric_name, 'Value': value, 'Unit': 'Count'}]
        )
    except Exception as e:
        print(f"CloudWatch Error: {e}")

# --- Polling Worker Thread ---
def polling_worker(endpoint, freq_per_hour, duration_hours):
    fill_rate = freq_per_hour / 3600.0
    bucket = TokenBucket(capacity=5, fill_rate=fill_rate)
    end_time = time.time() + (duration_hours * 3600)
    
    print(f"Worker started: Polling {endpoint}")

    while time.time() < end_time:
        wait_time = bucket.wait_for_tokens(1)
        if wait_time > 0:
            time.sleep(wait_time)
            continue

        try:
            # User-Agent to prevent 403s from APIs like GitHub
            headers = {'User-Agent': 'SRE-Polling-App/1.0'}
            resp = requests.get(endpoint, headers=headers, timeout=10)
            
            if resp.status_code == 429:
                put_metric('HTTP_429_Errors', 1)
                time.sleep(10)
                continue
                
            resp.raise_for_status()

            # SMART PARSING: Try JSON first, fallback to Text
            try:
                raw_data = resp.json()
                log_data = json.dumps(raw_data)
            except (ValueError, json.JSONDecodeError):
                log_data = resp.text[:1000]

            # Persistence
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute("INSERT INTO api_logs (data, status_code) VALUES (%s, %s)", 
                        (log_data, resp.status_code))
            conn.commit()
            cur.close()
            conn.close()
            
            put_metric('Successful_API_Calls', 1)
            print(f"Logged response from {endpoint}")
            
        except Exception as e:
            print(f"Polling Error: {e}")
            put_metric('Other_Errors', 1)

    print("Worker duration complete.")

@app.route('/', methods=['GET'])
def health():
    return jsonify({"status": "healthy"}), 200

@app.route('/start-polling', methods=['POST'])
def start():
    data = request.json
    try:
        url = data['endpoint']
        freq = int(data['frequency'])
        dur = int(data['duration'])

        thread = threading.Thread(target=polling_worker, args=(url, freq, dur))
        thread.daemon = True
        thread.start()
        return jsonify({"message": "Polling initiated"}), 202
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)
