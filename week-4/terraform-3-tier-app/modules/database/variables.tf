variable "environment" {
  description = "The environment for which the database is being provisioned (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the database will be provisioned"
  type        = string
}

variable "db_subnet_group_ids" {
  description = "List of subnet IDs for the database subnet group"
  type        = list(string)
}

variable "db_security_group" {
  description = "The security group for the database"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_user" {
  description = "The username for the database"
  type        = string
}

variable "db_engine" {
  description = "The database engine to use (e.g., mysql, postgres)"
  type        = string
}

variable "db_engine_mode" {
  description = "The database engine mode (e.g., provisioned, serverless)"
  type        = string
}

variable "db_engine_version" {
  description = "The version of the database engine to use"
  type        = string
}

variable "db_instance_class" {
  description = "The instance class for the database (e.g., db.t3.medium)"
  type        = string
}
