import boto3
import requests
import smtplib
import time
from email.mime.text import MIMEText

# --- CONFIGURATION ---
SENDER_EMAIL = "5abdulsami2004@gmail.com"
SENDER_APP_PASSWORD = "my-app-password"
RECEIVER_EMAIL = "abdul.sami@xgrid.co"
PROMETHEUS_URL = "http://localhost:9090/api/v1/query"
CLUSTER_NAME = "wordpress-ha-cluster"
LOG_GROUP = "/ecs/wordpress"

def get_instance_id():
    """Fetches the EC2 instance ID using IMDSv2"""
    try:
        # Step 1: Get Session Token
        token_url = "http://169.254.169.254/latest/api/token"
        headers = {"X-aws-ec2-metadata-token-ttl-seconds": "21600"}
        token = requests.put(token_url, headers=headers, timeout=2).text
        
        # Step 2: Get Instance ID using Token
        id_url = "http://169.254.169.254/latest/meta-data/instance-id"
        instance_id = requests.get(id_url, headers={"X-aws-ec2-metadata-token": token}, timeout=2).text
        return instance_id
    except Exception:
        return "Unknown-Instance"

def get_metric(query):
    try:
        response = requests.get(PROMETHEUS_URL, params={'query': query}, timeout=5).json()
        return round(float(response['data']['result'][0]['value'][1]), 2)
    except:
        return "N/A"

def get_logs_summary():
    client = boto3.client('logs', region_name='ap-south-1')
    try:
        # Fetches count of log events in the last hour
        query = client.filter_log_events(
            logGroupName=LOG_GROUP, 
            startTime=int((time.time() - 3600) * 1000)
        )
        return len(query.get('events', []))
    except:
        return "0 (Unable to fetch)"

def get_ecs_tasks():
    ecs = boto3.client('ecs', region_name='ap-south-1')
    try:
        tasks = ecs.list_tasks(cluster=CLUSTER_NAME)
        return len(tasks.get('taskArns', []))
    except Exception as e:
        return f"Error: {str(e)}"

def send_email(instance_id, cpu, disk, tasks, log_count):
    body = f"""
    SRE Daily Reliability Report
    ----------------------------
    Source Instance: {instance_id}
    System Health: {'OK' if isinstance(cpu, (int, float)) and cpu < 80 else 'WARNING'}
    
    Avg CPU (1h): {cpu}%
    Disk Usage: {disk}%
    Running ECS Tasks: {tasks}
    Logs Generated (1h): {log_count} events
    
    Failures/Restarts: 0 (Simulated)
    Recommendations: {'System stable' if (isinstance(cpu, str) or cpu < 80) else 'Check for CPU leaks'}
    """
    msg = MIMEText(body)
    msg['Subject'] = f'Daily SRE Report - {instance_id}'
    msg['From'] = SENDER_EMAIL
    msg['To'] = RECEIVER_EMAIL

    with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
        server.login(SENDER_EMAIL, SENDER_APP_PASSWORD)
        server.send_message(msg)

if __name__ == "__main__":
    print("Generating report...")
    inst_id = get_instance_id()
    cpu = get_metric('100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[1h])) * 100)')
    disk = get_metric('100 * (1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}))')
    tasks = get_ecs_tasks()
    logs = get_logs_summary()
    
    send_email(inst_id, cpu, disk, tasks, logs)
    print(f"Report sent for {inst_id}!")
