#!/bin/bash
# 1. Join ECS Cluster
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config

# 2. WordPress Directory Setup
mkdir -p /var/www/wordpress_data
chown -R 33:33 /var/www/wordpress_data
chmod 755 /var/www/wordpress_data

# 3. Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 4. Setup SRE Stack directory
mkdir -p /home/ec2-user/sre-stack
cd /home/ec2-user/sre-stack

# 5. Write configuration files from Terraform variables
cat << 'EOF' > prometheus.yml
${prometheus_config}
EOF

cat << 'EOF' > docker-compose.yml
${docker_compose}
EOF

cat << 'EOF' > daily_report.py
${report_script}
EOF

# 6. Install Python dependencies for the report
sudo pip3 install boto3 requests "urllib3<2"

# 7. Start the Monitoring Stack
sudo /usr/local/bin/docker-compose up -d

# 8. Setup Cron Job for Daily Report (9 AM)
(crontab -l 2>/dev/null; echo "0 9 * * * /usr/bin/python3 /home/ec2-user/sre-stack/daily_report.py >> /home/ec2-user/sre-stack/report.log 2>&1") | crontab -
