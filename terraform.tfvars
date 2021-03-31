###############################################################################################################################################################################
# Terraform loads variables in the following order, with later sources taking precedence over earlier ones:
# 
# Environment variables
# The terraform.tfvars file, if present.
# The terraform.tfvars.json file, if present.
# Any *.auto.tfvars or *.auto.tfvars.json files, processed in lexical order of their filenames.
# Any -var and -var-file options on the command line, in the order they are provided. (This includes variables set by a Terraform Cloud workspace.)
###############################################################################################################################################################################
#
# terraform cloud 와 별도로 동작
# terraform cloud 의 variables 와 동등 레벨
#
# Usage :
#
#   terraform apply -var-file=terraform.tfvars
#
#
# [Terraform Cloud] Environment Variables
#
#     AWS_ACCESS_KEY_ID
#     AWS_SECRET_ACCESS_KEY 
#

name = "example"

region = "us-west-2"

tags = {
  Terraform   = "true"
  Environment = "dev"
}

load_balancer_type = "application"
http_tcp_listeners = [
  {
    port               = 80
    protocol           = "HTTP"
    target_group_index = 0
  }
]

https_listeners = []
# [
#   {
#     port               = 443
#     protocol           = "HTTPS"
#     certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
#     target_group_index = 0
#   }
# ]

target_groups = [
  {
    name_prefix          = "http-"
    backend_protocol     = "HTTP"
    backend_port         = 80
    target_type          = "instance"
    deregistration_delay = 300
    health_check = {
      enabled             = true
      interval            = 30
      path                = "/"
      port                = "traffic-port"
      healthy_threshold   = 5
      unhealthy_threshold = 2
      timeout             = 5
      protocol            = "HTTP"
      matcher             = "200-399"
    }
    tags = {
      InstanceTargetGroupTag = "was"
    }
  }
]
