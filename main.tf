provider "aws" {
  # profile = "default"
  region = var.region
}

## Another Workspaces ##
# Workspace - vpc
data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "terraexam"
    workspaces = {
      name = "terraexam-aws-vpc"
    }
  }
}

# Workspace - security group
data "terraform_remote_state" "sg" {
  backend = "remote"
  config = {
    organization = "terraexam"
    workspaces = {
      name = "terraexam-aws-sg"
    }
  }
}

# Workspace - ec2
data "terraform_remote_state" "ec2" {
  backend = "remote"
  config = {
    organization = "terraexam"
    workspaces = {
      name = "terraexam-aws-ec2"
    }
  }
}

locals {
  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr_block      = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  public_subnet_ids   = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnet_ids  = data.terraform_remote_state.vpc.outputs.private_subnets
  database_subnet_ids = data.terraform_remote_state.vpc.outputs.database_subnets

  bastion_security_group_ids = ["${data.terraform_remote_state.sg.outputs.bastion_security_group_id}"]
  alb_security_group_ids     = ["${data.terraform_remote_state.sg.outputs.alb_security_group_id}"]
  was_security_group_ids     = ["${data.terraform_remote_state.sg.outputs.was_security_group_id}"]
  db_security_group_ids      = ["${data.terraform_remote_state.sg.outputs.db_security_group_id}"]

  bastion_ids = data.terraform_remote_state.ec2.outputs.bastion_ids
  was_ids     = data.terraform_remote_state.ec2.outputs.was_ids
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "${var.name}-alb"

  load_balancer_type = "application"

  vpc_id             = local.vpc_id
  subnets            = local.public_subnet_ids
  security_groups    = local.alb_security_group_ids

  # access_logs = {
  #   bucket = "my-alb-logs"
  # }

  target_groups = [
    {
      name_prefix      = "${var.name}-http-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  # https_listeners = [
  #   {
  #     port               = 443
  #     protocol           = "HTTPS"
  #     certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
  #     target_group_index = 0
  #   }
  # ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = var.tags
}