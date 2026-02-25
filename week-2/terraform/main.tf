terraform {
  required_version = ">= 1.4, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region_name
}

module "compute_module" {
  source        = "./modules/compute"
  instance_type = var.instance_type
  ami_id        = var.ami_id
  key_pair_name = var.key_name
  tags          = var.tags
  allowed_ip    = var.allowed_ip
}
