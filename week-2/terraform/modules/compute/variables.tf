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
  type = map(string)
}

variable "allowed_ip" {
  description = "The CIDR block allowed for access"
  type        = string
}
