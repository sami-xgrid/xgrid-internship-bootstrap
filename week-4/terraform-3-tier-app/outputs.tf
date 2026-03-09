output "vpc_id" {
  description = "The ID of the VPC"
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value = module.vpc.private_subnet_ids
}

output "web_sg_id" {
  description = "The ID of the security group for the web tier"
  value = module.security.web_sg_id
}

output "app_sg_id" {
  description = "The ID of the security group for the app tier"
  value = module.security.app_sg_id
}

output "db_sg_id" {
  description = "The ID of the security group for the db tier"
  value = module.security.db_sg_id
}

output "db_cluster_endpoint" {
  description = "The endpoint of the Aurora cluster"
  value       = module.database.cluster_endpoint
}

