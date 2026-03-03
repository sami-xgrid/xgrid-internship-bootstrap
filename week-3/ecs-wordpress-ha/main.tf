module "networking" {
  source   = "./modules/networking"
  vpc_cidr = "10.0.0.0/16"
}

module "storage" {
  source             = "./modules/storage"
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnets
  ecs_sg_id          = module.networking.ecs_sg_id
}

module "database" {
  source             = "./modules/database"
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnets
  ecs_sg_id          = module.networking.ecs_sg_id
  db_username        = var.db_username
  db_password        = var.db_password
}