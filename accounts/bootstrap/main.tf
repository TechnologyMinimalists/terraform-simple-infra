# Configure the AWS Provider
provider "aws" {
  region = var.region
}

terraform {
  required_version = "~>0.12"

  backend "local" {
    path = "tfstate/terraform.local-tfstate"
  }
}

#resource "aws_s3_bucket" "terraform_state" {
#  bucket        = "terraform-states"
#  acl           = "private"
#  force_destroy = false
#
#  versioning {
#    enabled = true
#  }
#
#  server_side_encryption_configuration {
#    rule {
#      apply_server_side_encryption_by_default {
#        sse_algorithm = "AES256"
#      }
#    }
#  }
#}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "terraform-state-lock"
  hash_key       = "LockID"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
}
