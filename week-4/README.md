# Week 4: 3-Tier Web Application on AWS

## Architecture Overview

This project implements a 3-tier web application using AWS infrastructure:

1. **Presentation Tier (React.js + Nginx):**
   Hosted on an EC2 instance in a public subnet. Nginx serves the React application on port 80 and reverse proxies `/api/` traffic directly to the backend EC2 server.

2. **Application Tier (Python Flask):**
   Hosted on an EC2 instance in a private subnet. Exposes a REST API port 5000 to manage a background polling worker. The worker accepts an API endpoint, frequency, and duration, then gracefully polls using a Token Bucket rate-limiting algorithm.

3. **Database Tier (Amazon Aurora Serverless):**
   Deployed in private subnets across multiple AZs. Configured with IAM database authentication to securely accept API poll results (JSON structure and HTTP status code) inserted by the backend.

### Key Infrastructure Services
- **VPC** with Public/Private Subnets and NAT Gateway
- **Security Groups:** Explicit ingress rules linking Web -> App -> DB
- **CloudWatch:** Dashboard tracks successful and failed (HTTP 429 and others) API calls made by the background worker.

## Environment Breakdown
- **Frontend:** Code in `./frontend`
- **Backend:** Code in `./backend`
- **Infrastructure:** Code in `./terraform-3-tier-app`

---

## GenAI Usage Documentation

- **Tool Used:** Gemini Advanced (Google Deepmind Assistant)
- **Specific Prompts/Questions Asked:**
  1. *Fix my week-4 folder infrastructure to include rate limiting with graceful sleep and CloudWatch metric dashboards.*
  2. *Help dynamically inject my Application Backend IP to Nginx resolving without manual reconfiguration in Docker.*
- **Reflection:** Using GenAI saved substantial time, primarily by automating the boilerplate definitions of the CloudWatch dashboard in Terraform and scaffolding out an efficient Token Bucket rate-limiting algorithm avoiding busy-waits.
- **Influence on Final Solution:** The graceful degradation (using wait intervals based on specific 429 handling and bucket depletion) and the `user_data` injection of `/etc/hosts` for frontend proxy routing were completely influenced by GenAI's recommendations for best practices.

## Infrastructure Deployment

To deploy the infrastructure, ensure you have configured your AWS credentials.
```bash
cd terraform-3-tier-app
terraform init
terraform apply
```

To destroy the infrastructure after testing:
```bash
terraform destroy
```
*(Screenshot demonstrating the successful execution of `terraform destroy` would act as proof of completion).*
