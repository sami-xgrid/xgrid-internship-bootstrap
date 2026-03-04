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