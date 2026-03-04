variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EC2 instances"
  type        = list(string)
}

variable "ecs_sg_id" {
  description = "Security Group ID for the ECS instances/tasks"
  type        = string
}

variable "alb_sg_id" {
  description = "Security Group ID for the Load Balancer"
  type        = string
}