# This is for a common VPC and services - though it'll be used only for staging
# Services:
# - Jenkins
# - Sentry
# - VPC + Peering to main VPC controlled by Ansible
module "common_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v2.0"

  name = "Common VPC"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true

  tags = {
    ManagedBy   = "Terraform"
    Environment = "Common"
  }
}

module "vpc_peering" {
  source = "./modules/vpc_peering"

  accepter_region  = var.region
  requester_region = var.region
  accepter_vpc_id  = data.aws_vpc.staging_ansible.id
  requester_vpc_id = module.common_vpc.vpc_id
}

# EC2 instance
module "jenkins_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = "jenkins"
  key_name = "staging_frankfurt"
  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  lc_name = "jenkins-lc"

  # Created using packer
  image_id        = "ami-099a56a63adcd368b"
  instance_type   = "t2.small"
  security_groups = [aws_security_group.jenkins.id, aws_security_group.allow_ssh.id]
  load_balancers  = [module.jenkins_elb.this_elb_id]

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "jenkins-asg"
  vpc_zone_identifier       = module.common_vpc.private_subnets
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "staging"
      propagate_at_launch = true
    },
    {
      key                 = "Managedby"
      value               = "Terraform"
      propagate_at_launch = true
    },
  ]
}

# Get Route53 zone
data "aws_route53_zone" "selected" {
  name         = "dev.technologyminimalists.com"
  private_zone = false
}

# Add record
resource "aws_route53_record" "jenkins_dev" {
  name = "jenkins.dev.technologyminimalists.com"
  records = [module.jenkins_elb.this_elb_dns_name]
  type = "CNAME"
  zone_id = data.aws_route53_zone.selected.id
  ttl = 300
}

# Create SSL certificate
module "jenkins_dev_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name  = "jenkins.dev.technologyminimalists.com"
  zone_id      = data.aws_route53_zone.selected.id

  tags = {
    Name = "jenkins.dev.technologyminimalists.com"
  }
}

resource "aws_security_group" "jenkins" {
  name   = "Allow HTTP and HTTPS"
  vpc_id = module.common_vpc.vpc_id

  ingress {
    description = "Allow HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "Allow access HTTP+HTTPS"
    Managedby = "Terraform"
  }
}

resource "aws_security_group" "allow_ssh" {
  name   = "Allow SSH access"
  vpc_id = module.common_vpc.vpc_id

  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "Allow SSH"
    Managedby = "Terraform"
  }
}

# ELB for Jenkins
module "jenkins_elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = "~> 2.0"

  name = "jenkins"

  subnets         = module.common_vpc.public_subnets
  security_groups = [aws_security_group.jenkins.id]
  internal        = false


  listener = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "443"
      lb_protocol       = "HTTPS"
      ssl_certificate_id = module.jenkins_dev_certificate.this_acm_certificate_arn
    },
  ]

  health_check = {
    target              = "TCP:80"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = {
    Environment = "staging"
    Managedby = "Terraform"
  }
}
