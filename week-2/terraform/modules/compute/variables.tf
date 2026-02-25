variable "instance_type" {
    description = "Instance type for the EC2 instance"
    type        = string
}

variable "ami_id" {
    description = "AMI ID for the EC2 instance"
    type        = string
}

variable "key_pair_name" {
  description = "Key Pair to allow SSH into instance"
  type = string
}

variable "tags" {
  description = "Standard tags for Xgrid resources"
  type        = map(string)
  default     = {
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
