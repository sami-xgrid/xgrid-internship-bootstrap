module "compute" {
  source             = "./modules/compute"
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnets
  private_subnet_ids = module.networking.private_subnets
  ecs_sg_id          = module.networking.ecs_sg_id
  alb_sg_id          = module.networking.alb_sg_id
}

module "networking" {
  source   = "./modules/networking"
  vpc_cidr = "10.0.0.0/16"
}

module "database" {
  source             = "./modules/database"
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnets
  ecs_sg_id          = module.networking.ecs_sg_id
  db_username        = var.db_username
  db_password        = var.db_password
}

module "wordpress" {
  source             = "./modules/wordpress"
  cluster_id         = module.compute.cluster_id
  execution_role_arn = module.compute.ecs_task_execution_role_arn
  target_group_arn   = module.compute.target_group_arn
  private_subnet_ids = module.networking.private_subnets
  ecs_sg_id          = module.networking.ecs_sg_id

  # Connect to your DB module
  db_host     = module.database.db_endpoint
  db_user     = var.db_username # Assuming you have these variables in root
  db_password = var.db_password
  db_name     = "wordpressdb"
}
