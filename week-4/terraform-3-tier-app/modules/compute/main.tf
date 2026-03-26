# Frontend EC2 (Public)
resource "aws_instance" "frontend" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.web_sg_id]
  iam_instance_profile        = var.frontend_iam_profile
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              
              # Map backend-service at OS level
              echo "${aws_instance.backend.private_ip} backend-service" | tee -a /etc/hosts

              # Authenticate and Run with Host Mapping for Docker
              aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
              docker pull ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/sre-frontend:latest
              docker run -d -p 80:80 \
                --name frontend \
                --add-host backend-service:${aws_instance.backend.private_ip} \
                ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/sre-frontend:latest
              EOF
  tags      = var.tags
}

# Backend EC2 (Private)
resource "aws_instance" "backend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.app_sg_id]
  iam_instance_profile   = var.backend_iam_profile

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user

              # Authenticate and Run
              aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
              docker pull ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/sre-backend:latest
              docker run -d -p 5000:5000 \
                --name backend \
                -e DB_HOST=${var.db_host} \
                -e DB_NAME=${var.db_name} \
                -e AWS_REGION=${var.aws_region} \
                ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/sre-backend:latest
              EOF
  tags      = var.tags
}
