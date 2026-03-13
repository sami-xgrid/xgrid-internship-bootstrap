terraform {
  backend "s3" {
    bucket         = "my-unique-terraform-state-bucket-2033513"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
