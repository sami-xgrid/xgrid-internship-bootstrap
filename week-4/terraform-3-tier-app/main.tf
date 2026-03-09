module "vpc" {
  source          = "./modules/vpc"
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "security" {
  source           = "./modules/security"
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  allowed_admin_ip = var.allowed_admin_ip
}

module "database" {
  source              = "./modules/database"
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  db_subnet_group_ids = module.vpc.private_subnet_ids
  db_security_group   = module.security.db_sg_id
  db_name             = var.db_name
  db_user             = var.db_user
  db_engine           = var.db_engine
  db_engine_mode      = var.db_engine_mode
  db_engine_version   = var.db_engine_version
  db_instance_class   = var.db_instance_class
}
