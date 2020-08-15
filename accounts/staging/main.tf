data "aws_vpc" "staging_ansible" {
  tags = {
    Name = "Staging"
  }
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.staging_ansible.id

  tags = {
    Name = "Staging Private*"
  }
}
