## Use local state for now
#terraform {
#  required_version = "~>0.12"
#
#  backend "s3" {
#    bucket         = "terraform-states"
#    key            = "staging/terraform.tfstate"
#    region         = "eu-central-1"
#    encrypt        = true
#    dynamodb_table = "terraform-state-lock"
#    //    role_arn = "arn:aws:iam::PRODUCTION-ACCOUNT-ID:role/Terraform"
#  }
#}

provider "aws" {
  region = var.region
}
