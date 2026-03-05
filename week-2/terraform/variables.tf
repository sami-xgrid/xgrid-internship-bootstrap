variable "region_name" {
  description = "AWS Region for the resources to be deployed"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Key Pair name to allow SSH into instance"
  type        = string
}

variable "tags" {
  description = "Standard tags for Xgrid resources"
  type        = map(string)
  default = {
    app         = "EC2-SG-Module"
    created-by  = "Terraform"
    environment = "XLDP - Dev"
    project     = "Module_Name - XLDP"
    owner       = "abdul.sami@xgrid.co"
    creator     = "abdul.sami@xgrid.co"
    team        = "Firebirds"
  }
}

variable "allowed_ip" {
  description = "The CIDR block allowed for access"
  type        = string
}
