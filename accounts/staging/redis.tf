// Generate a random string for auth token, no special chars
resource "random_string" "redis_auth_token" {
  length  = 64
  special = false
}

data "aws_security_group" "web_service" {
  vpc_id = data.aws_vpc.staging_ansible.id
  name   = "Staging web Security Group"
}

module "staging_redis" {
  source    = "git::https://github.com/cloudposse/terraform-aws-elasticache-redis.git?ref=9904a81caa17bbf6abf7e3b82fdfa0ac7aa1215a"
  namespace = "staging"
  stage     = var.environment
  name      = "redis"

  // from which security group we can get to the redis service
  allowed_security_groups = [
    data.aws_security_group.web_service.id
  ]

  auth_token         = random_string.redis_auth_token.result
  vpc_id             = data.aws_vpc.staging_ansible.id
  subnets            = data.aws_subnet_ids.all.ids
  maintenance_window = "wed:03:00-wed:04:00"
  cluster_size       = 1
  instance_type      = "cache.t2.micro"
  engine_version     = "5.0.6"
  family             = "redis5.0"
  //  alarm_cpu_threshold_percent  = var.cache_alarm_cpu_threshold_percent
  //  alarm_memory_threshold_bytes = var.cache_alarm_memory_threshold_bytes
  apply_immediately  = true
  availability_zones = ["eu-central-1b", "eu-central-1c"]
  //  automatic_failover           = "false"
  transit_encryption_enabled = false
  at_rest_encryption_enabled = true
}

output "redis_auth_token" {
  value = random_string.redis_auth_token.result
}
