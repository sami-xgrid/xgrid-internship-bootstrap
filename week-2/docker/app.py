from flask import Flask, jsonify
import shutil
import os

app = Flask(__name__)

@app.route('/health')
def health_check():
    # Basic logic: Check disk space and return "Healthy"
    total, used, free = shutil.disk_usage("/")
    return jsonify({
        "status": "Healthy",
        "container_id": os.uname()[1],
        "free_space_gb": free // (2**30)
    }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=4000)
