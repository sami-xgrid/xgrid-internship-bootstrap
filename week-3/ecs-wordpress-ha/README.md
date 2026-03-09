# Highly Available WordPress on AWS ECS (Terraform Managed)

![Architecture Diagram](./wordpress-aws-infra.png)

## 1. Architecture Explanation
This deployment utilizes a multi-tier, highly available (HA) architecture designed to survive Availability Zone (AZ) failures while maintaining a minimal cost footprint.

* **Networking:** A custom VPC spans two Availability Zones in the `ap-south-1` region. It consists of two public subnets for the Application Load Balancer (ALB) and NAT Gateway, and two private subnets for the application and database layers.
* **Compute:** The ECS Cluster uses the EC2 launch type. An Auto Scaling Group (ASG) manages `t3.micro` instances across both AZs, integrated with an ECS Capacity Provider to ensure resources scale based on container demand.
* **Orchestration:** WordPress is deployed as an ECS Service with a `desired_count` of 2. It utilizes `awsvpc` network mode, providing each task with its own Elastic Network Interface (ENI) for security and performance.
* **Database:** Amazon RDS MySQL 8.0 is deployed in a Multi-AZ configuration. This provides a primary instance in one AZ and a synchronous standby in the second AZ for automatic failover.
* **Security:** IAM roles follow the principle of least privilege, separating Task Execution (fetching secrets) from Node operations. All database credentials and hostnames are stored in AWS SSM Parameter Store and injected as environment variables at runtime.

## 2. Deployment Steps

### Step 1: Initialize Terraform
Prepare the working directory and download the required providers.
```
terraform init
```

### Step 2: Plan the Infrastructure

Review the execution plan to verify the 14+ resources being created.

```bash
terraform plan -var="db_password=YourSecurePassword"

```

### Step 3: Apply Configuration

Provision the infrastructure. In the event of a timeout or crash, use manual imports to sync the state.

```bash
terraform apply -var="db_password=YourSecurePassword"

```

### Step 4: Access the Application

Capture the `wordpress_url` from the Terraform output and verify the site in a web browser.

## 3. Known Limitations

* **Storage Persistence:** This deployment currently uses local host-path bind mounts for `/var/www/wordpress_data`. Because storage is local to the EC2 instance, data is not shared between tasks running on different nodes.
* **Scaling Constraint:** If a task moves to a new instance during a scaling event or host failure, uploaded media files residing on the previous host will not be accessible.
* **Production Recommendation:** For full state synchronization, Amazon EFS (Elastic File System) should be implemented to provide a shared persistent volume across all AZs.

## 4. Cost Analysis (SRE Review)

The architecture is optimized to remain within the AWS Free Tier for 12 months.

* **EC2:** 750 hours per month of `t3.micro` instances are covered under the Free Tier.
* **RDS:** 750 hours per month of `db.t3.micro` (Multi-AZ) and 20GB of General Purpose (SSD) storage are included.
* **ALB:** 750 hours per month and 15 LCU (Load Balancer Capacity Units) are included.
* **SSM & CloudWatch:** Standard usage for parameter storage and logging falls within the free usage tier limits.

## 5. Troubleshooting Guide

* **503 Service Unavailable:** This typically occurs when the ALB has no healthy targets. This was resolved by increasing the `health_check_grace_period_seconds` to 300 to allow the WordPress PHP-FPM process to fully initialize.
* **Terraform State Lock:** If a deployment is interrupted, the state may lock. Use `terraform force-unlock <LockID>` only after verifying no other processes are modifying the infrastructure.
* **Resource Conflict (EntityAlreadyExists):** If resources were created during a crashed session but not recorded in the `.tfstate`, use `terraform import <module.path.resource> <aws_resource_id>` to re-sync the state.
* **Database Connection Error:** Verify that the RDS Security Group allows inbound traffic on port 3306 from the ECS Security Group.

## 6. GenAI Utilization & Reflection

* **Tool(s) Used:** Gemini 3 Flash and Github Copilot.
* **Specific Prompts:** * "How to resolve EntityAlreadyExists error for IAM roles in Terraform after a crash?"
    * "How to import an existing AWS RDS instance into Terraform state?"
    * "Troubleshooting 503 Service Unavailable for WordPress on ECS behind an ALB."
* **Influence on Solution:** Gemini provided the recovery commands (terraform import) needed to resync the state file after a system crash. GitHub Copilot was utilized to verify the project structure, cross-reference variable definitions across modules, and ensure consistency in the `.tf` files.
* **Reflection:** These tools significantly saved time by providing immediate syntax for state recovery. Copilot specifically reduced manual overhead by suggesting boilerplate code and catching variable naming inconsistencies during the setup phase.
