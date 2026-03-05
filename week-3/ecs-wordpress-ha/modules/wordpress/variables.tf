variable "cluster_id" {}
variable "execution_role_arn" {}
variable "target_group_arn" {}
variable "private_subnet_ids" { type = list(string) }
variable "ecs_sg_id" {}
variable "db_host" {}
variable "db_user" {}
variable "db_password" {}
variable "db_name" {}
variable "region" { default = "ap-south-1" }