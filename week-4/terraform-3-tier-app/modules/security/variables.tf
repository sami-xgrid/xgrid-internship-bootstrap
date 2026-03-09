variable "environment" {
  description = "The environment for which the security group is being provisioned (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to which the security group belongs"
  type        = string
}

variable "allowed_admin_ip" {
  description = "The IP address allowed to access the admin interface"
  type        = string
}
     