// Generate a random string for auth token, no special chars
resource "random_string" "postgres_auth_token" {
  length  = 64
  special = false
}

resource "aws_security_group" "rds_staging" {
  name   = "Allow RDS access"
  vpc_id = data.aws_vpc.staging_ansible.id

  ingress {
    description = "Allow RDS access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.staging_ansible.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "Allow Postgresql access - RDS"
    Managedby = "Terraform"
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "staging-web"

  engine            = "postgres"
  engine_version    = "11"
  instance_class    = "db.t2.xlarge"
  allocated_storage = 5
  storage_encrypted = false

  # kms_key_id        = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
  name = "stagingweb"

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  username = var.rds_user

  password = random_string.postgres_auth_token.result
  port     = "5432"

  vpc_security_group_ids = [aws_security_group.rds_staging.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = {
    Managedby   = "Terraform"
    Environment = var.environment
  }

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # DB subnet group
  subnet_ids = data.aws_subnet_ids.all.ids

  # DB parameter group
  family = "postgres11"

  # DB option group
  major_engine_version = "11"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "staging-web-final-snapshot"

  # Database Deletion Protection
  deletion_protection = false
}


output "postgres_auth_token" {
  value = random_string.postgres_auth_token.result
}
