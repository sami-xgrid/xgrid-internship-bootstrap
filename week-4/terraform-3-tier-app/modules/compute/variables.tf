variable "vpc_id" {
  description = "The ID of the VPC to which the EC2 instances will be deployed"
  type        = string
}

variable "public_subnet_id" {
  description = "The ID of the public subnet to which the frontend EC2 instance will be deployed"
  type        = string
}

variable "private_subnet_id" {
  description = "The ID of the private subnet to which the backend EC2 instance will be deployed"
  type        = string
}

variable "web_sg_id" {
  description = "The ID of the security group for the frontend EC2 instance"
  type        = string
}

variable "app_sg_id" {
  description = "The ID of the security group for the backend EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
}

variable "backend_iam_profile" {
  description = "The name of the IAM instance profile for the backend EC2 instance"
  type        = string
}

variable "frontend_iam_profile" {
  description = "The name of the IAM instance profile for the frontend EC2 instance"
  type        = string
}

variable "db_host" {
  description = "The endpoint of the Database"
  type        = string
}

variable "db_name" {
  description = "The name of the Database"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "tags" {
  description = "Tags for the EC2 instances"
  type        = map(string)
}
