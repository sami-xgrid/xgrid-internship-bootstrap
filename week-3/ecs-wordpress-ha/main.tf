# VPC, subnets, and security groups — everything else depends on this
module "networking" {
  source          = "./modules/networking"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

# ALB, ECS cluster, ASG, and IAM roles — wordpress tasks run on top of this
module "compute" {
  source             = "./modules/compute"
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnets
  private_subnet_ids = module.networking.private_subnets
  ecs_sg_id          = module.networking.ecs_sg_id
  alb_sg_id          = module.networking.alb_sg_id
}

# RDS instance isolated in private subnets, only reachable from ECS SG
module "database" {
  source             = "./modules/database"
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnets
  ecs_sg_id          = module.networking.ecs_sg_id
  db_username        = var.db_username
}

# ECS task definition and service — wires the cluster, ALB target group, and RDS together
module "wordpress" {
  source             = "./modules/wordpress"
  cluster_id         = module.compute.cluster_id
  execution_role_arn = module.compute.ecs_task_execution_role_arn
  target_group_arn   = module.compute.target_group_arn
  private_subnet_ids = module.networking.private_subnets
  ecs_sg_id          = module.networking.ecs_sg_id

  db_host_arn     = module.database.db_host_arn
  db_user_arn     = module.database.db_user_arn
  db_password_arn = module.database.db_password_arn
  db_name         = "wordpressdb"
}
