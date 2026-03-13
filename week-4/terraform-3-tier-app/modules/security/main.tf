resource "aws_security_group" "web" {
  name_prefix = "${var.tags["app"]}-web-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_admin_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_security_group" "app" {
  name_prefix = "${var.tags["app"]}-app-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_security_group" "db" {
  name_prefix = "${var.tags["app"]}-db-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = var.tags
}

# IAM Role for Backend EC2
resource "aws_iam_role" "backend_role" {
  name = "${var.tags["app"]}-backend-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# IAM Role for Frontend EC2
resource "aws_iam_role" "frontend_role" {
  name = "${var.tags["app"]}-frontend-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Policy for IAM Database Authentication and CloudWatch Metrics
resource "aws_iam_role_policy" "backend_policy" {
  name = "BackendPolicy"
  role = aws_iam_role.backend_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "rds-db:connect"
        Effect   = "Allow"
        Resource = "arn:aws:rds-db:${var.aws_region}:${var.account_id}:dbuser:*/*"
      },
      {
        Action   = "cloudwatch:PutMetricData"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Instance Profile to attach to Backend EC2
resource "aws_iam_instance_profile" "backend_profile" {
  name = "${var.tags["app"]}-backend-profile"
  role = aws_iam_role.backend_role.name
}

# Instance Profile to attach to Frontend EC2
resource "aws_iam_instance_profile" "frontend_profile" {
  name = "${var.tags["app"]}-frontend-profile"
  role = aws_iam_role.frontend_role.name
}

# SSM Managed Instance Core policies
resource "aws_iam_role_policy_attachment" "backend_ssm_managed" {
  role       = aws_iam_role.backend_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "frontend_ssm_managed" {
  role       = aws_iam_role.frontend_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ECR Read Only policies
resource "aws_iam_role_policy_attachment" "backend_ecr_read" {
  role       = aws_iam_role.backend_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "frontend_ecr_read" {
  role       = aws_iam_role.frontend_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
