variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "environment" {
  description = "The environment for which resources are being provisioned"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "allowed_admin_ip" {
  description = "The IP address allowed to access the admin interface"
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
  description = "The database engine to use"
  type        = string
}
variable "db_engine_mode" {
  description = "The database engine mode"
  type        = string
}
variable "db_engine_version" {
  description = "The version of the database engine to use"
  type        = string
}
variable "db_instance_class" {
  description = "The instance class for the database"
  type        = string
}
