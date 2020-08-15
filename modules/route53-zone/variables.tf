variable "zone_name" {
  description = "Zone name, eg. example.com"
  type        = "string"
}

variable "private" {
  description = "Private or public zone - if private, it must be paired with VPC"
  default     = true
}

variable "vpc_id" {
  description = "VPC ID in case if private zone, MUST be set if var.private is true"
  default     = ""
}

variable "tags" {
  description = "Tags for the resource"
  type        = "map"

  default = {
    Comment = "Managed by Terraform"
  }
}
