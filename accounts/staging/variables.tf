variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "rds_user" {
  type    = string
  default = "therootuser"
}

variable "environment" {
  type    = string
  default = "staging"
}
