module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.tags
}

module "security" {
  source           = "./modules/security"
  aws_region       = var.aws_region
  vpc_id           = module.vpc.vpc_id
  allowed_admin_ip = var.allowed_admin_ip
  account_id       = data.aws_caller_identity.current.account_id
  tags             = var.tags
}

module "database" {
  source              = "./modules/database"
  db_subnet_group_ids = module.vpc.private_subnet_ids
  db_security_group   = module.security.db_sg_id
  db_name             = var.db_name
  db_user             = var.db_user
  db_engine           = var.db_engine
  db_engine_mode      = var.db_engine_mode
  db_engine_version   = var.db_engine_version
  db_instance_class   = var.db_instance_class
  tags                = var.tags
}

module "compute" {
  source               = "./modules/compute"
  ami_id               = var.ami_id
  vpc_id               = module.vpc.vpc_id
  public_subnet_id     = module.vpc.public_subnet_ids[0]
  private_subnet_id    = module.vpc.private_subnet_ids[0]
  web_sg_id            = module.security.web_sg_id
  app_sg_id            = module.security.app_sg_id
  backend_iam_profile  = module.security.backend_instance_profile
  frontend_iam_profile = module.security.frontend_instance_profile
  db_host              = module.database.cluster_endpoint
  db_name              = var.db_name
  aws_region           = var.aws_region
  account_id           = data.aws_caller_identity.current.account_id
  tags                 = var.tags

  depends_on = [
    aws_ecr_repository.sre_frontend,
    aws_ecr_repository.sre_backend,
    module.database
  ]
}

# Helper to get Account ID for IAM policy
data "aws_caller_identity" "current" {}

# ECR Repositories
resource "aws_ecr_repository" "sre_frontend" {
  name                 = "sre-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  tags                 = var.tags
}

resource "aws_ecr_repository" "sre_backend" {
  name                 = "sre-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  tags                 = var.tags
}

# CloudWatch Dashboard for Polling Metrics
resource "aws_cloudwatch_dashboard" "app_dashboard" {
  dashboard_name = "${var.tags["app"]}-Monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["XLDP/PollingApp", "Successful_API_Calls"],
            [".", "HTTP_Errors"],
            [".", "HTTP_429_Errors"],
            [".", "Other_Errors"]
          ]
          period = 60
          stat   = "Sum"
          region = var.aws_region
          title  = "Polling App API Call Metrics"
        }
      }
    ]
  })
}
