# SRE Operational Runbook: WordPress HA & Monitoring

## 1. Overview
This runbook provides the necessary operational context for managing the High-Availability (HA) WordPress infrastructure. It ensures that any SRE can maintain, troubleshoot, and scale the environment while utilizing the integrated Prometheus/Grafana monitoring stack.

## 2. Infrastructure Architecture
The system is built on a "Zero-Touch" deployment model using Terraform.
* **Compute:** Amazon ECS (EC2 Launch Type) within an Auto Scaling Group.
* **Database:** Amazon RDS (MySQL) for persistent storage.
* **Observability:** A sidecar-style monitoring stack (Prometheus, Grafana, Node Exporter) running on each container host.
* **Reporting:** A Python-based automation agent that triggers daily health snapshots.

## 3. Monitoring & Observability
### Accessing the Dashboard
Since the infrastructure resides in a private subnet, access to Grafana is secured via an SSM Tunnel.
1.  Identify a target Instance ID: `aws ec2 describe-instances ...`
2.  Establish a tunnel:
    ```bash
    aws ssm start-session --target <INSTANCE_ID> --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["3000"],"localPortNumber":["3000"]}'
    ```
3.  Navigate to `http://localhost:3000` (Credentials: `admin`/`admin`).

### Key Metrics to Track
| Metric | Threshold | Action if Exceeded |
| :--- | :--- | :--- |
| **CPU Usage** | > 80% for 5 mins | Inspect for runaway PHP processes or scale the ASG. |
| **Disk Usage** | > 85% | Check log rotation or clear `/var/lib/docker/overlay2`. |
| **ECS Task Count** | < Desired Count | Investigate task exit codes in CloudWatch Logs. |

## 4. Daily Reliability Report
The system generates a daily email report at **09:00 UTC**. 
* **Source:** `~/sre-stack/daily_report.py`
* **Integration:** The script utilizes **IMDSv2** to identify the reporting node and **Boto3** to query the AWS environment.
* **Failure Log:** If a report is not received, check the cron logs on the instance at `/home/ec2-user/sre-stack/report.log`.

## 5. Incident Response & Troubleshooting
### Scenario A: High CPU or Latency
1.  Log in to Grafana and identify the specific Instance ID with high utilization.
2.  SSM into the instance and run `top` or `htop` to identify the specific container.
3.  Check WordPress logs for plugin conflicts or heavy traffic.

### Scenario B: ECS Tasks Failing to Start
1.  Check the `wordpress-task-execution-role` permissions in `iam.tf`.
2.  Review the `user_data.sh` logs on the host: `cat /var/log/user-data.log`.
3.  Ensure the RDS endpoint is reachable from the container subnet.

## 6. Deployment & Maintenance
### Updating Configuration
To update the monitoring stack or the reporting script:
1.  Modify the files in `week-6/sre-stack/`.
2.  Run `terraform apply` from the `week-3/ecs-wordpress-ha/` directory.
3.  **Note:** This will trigger a rolling replacement of instances to apply the new `user_data`.

### Manual Recovery (Emergency Only)
If the automated setup fails on boot:
* Re-run the configuration script: `sudo /usr/local/bin/docker-compose -f ~/sre-stack/docker-compose.yml up -d`.
* Validate IAM connectivity: `python3 ~/sre-stack/daily_report.py` (check for 403 Forbidden errors).

## 7. SRE Checklist (Standard Procedures)
* [ ] **Daily:** Review the Reliability Report for abnormal task restarts.
* [ ] **Weekly:** Export and archive the Grafana JSON model to the repository.
* [ ] **Monthly:** Audit IAM roles to ensure Principle of Least Privilege (PoLP).

---

### **Author's Note**
This environment was transitioned from a manual "ClickOps" setup to a fully automated Infrastructure-as-Code (IaC) model. All components are self-healing; if an instance is terminated, the Auto Scaling Group will re-provision it with the full SRE stack within 180 seconds.
