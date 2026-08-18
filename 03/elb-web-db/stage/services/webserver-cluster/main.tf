# https://registry.terraform.io/providers/hashicorp/aws/latest/docs#example-usage
provider "aws" {
  region = "us-east-2"
}

# 
# Web Server
# LB - TG(ASG)
# 
# 1. Default VPC
#   * Subnet
# 2. LB - TG(ASG)
#   (생성 순서 중요)
#   * TG -> LB
#   * LT -> ASG
#   * TG -> LT -> ASG
#   (1) LB 생성
#     - SG 생성
#     - TG 생성
#     - LB 생성
#     - LB Listener 생성
#     - LB Listener rule 생성
#   (2) ASG 생성 
#     - SG 생성
#     - LT 생성(EC2 템플릿 - mykeypair, user_data)
#     - ASG 생성
#

#
# 1. Default VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc#example-usage
#
data "aws_vpc" "default" {
  default = true
}

#   * Subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets#example-usage
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# terraform_remote_state data_source
# https://developer.hashicorp.com/terraform/language/backend/s3#data-source-configuration
data "terraform_remote_state" "myRemoteState" {
  backend = "s3"
  config = {
    bucket = "bucket-jth-1103"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

#
# 2. LB - TG(ASG)
#   (1) LB 생성
#

#     - SG 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#example-usage
resource "aws_security_group" "myLB_SG" {
  name        = "myLB_SG"
  description = "Allow 80/tcp inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myLB_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_80" {
  security_group_id = aws_security_group.myLB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.myLB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#     - TG 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#example-usage
resource "aws_lb_target_group" "myLB_TG" {
  name     = "myLB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

#     - LB 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#application-load-balancer
resource "aws_lb" "myLB" {
  name               = "myLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myLB_SG.id]
  subnets            = data.aws_subnets.default.ids
}

#     - LB Listener 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener#forward-action
resource "aws_lb_listener" "myLB_Listener" {
  load_balancer_arn = aws_lb.myLB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myLB_TG.arn
  }
}

#     - LB Listener rule 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#example-usage
# LB Listener 생성할 때 default_action 값을 설정했으므로
# 다른 규칙 만들지 않는다면 LB Listener rule을 작성하지 않아도 괜찮음.
# LB Listener rule은 최소 1개 이상 있는 것이 조건.
resource "aws_lb_listener_rule" "myLB_Listener_rule" {
  listener_arn = aws_lb_listener.myLB_Listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myLB_TG.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

#   (2) ASG 생성 
#     - SG 생성
# ASG의 SG는 기존에 생성한 LB의 SG를 사용

# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ami#example-usage
# Create an AMI that will start a machine whose root device is backed by
# an EBS volume populated from a snapshot. We assume that such a snapshot
# already exists with the id "snap-xxxxxxxx".

# aws_ami
# LT 생성시 aws_ami.id가 필요
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#basic-example-using-ami-lookup
data "aws_ami" "amz2023ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.18-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

#     - LT 생성(EC2 템플릿 - mykeypair, user_data)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#example-usage
#
# * user-data.sh 
#   #!/bin/bash
#   cat > index.html <<EOF
#   <h1>Hello, World</h1>
#   <p>DB address: ${db_address}</p>
#   <p>DB port: ${db_port}</p>
#   EOF
#   nohup busybox httpd -f -p ${server_port} &
#
resource "aws_launch_template" "myLT" {
  name = "myLT"
  image_id = data.aws_ami.amz2023ami.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.myLB_SG.id]
  user_data = base64encode(templatefile("user_data.sh", {
    db_address = data.terraform_remote_state.myRemoteState.outputs.dbIP
    db_port = data.terraform_remote_state.myRemoteState.outputs.dbPort
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "myLT"
    }
  }
}


#     - ASG 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#with-latest-version-of-launch-template
# - target_group_arns
# - depends_on
resource "aws_autoscaling_group" "myASG" {
  vpc_zone_identifier = data.aws_subnets.default.ids
  desired_capacity    = 2
  max_size            = 10
  min_size            = 1

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#vpc_zone_identifier-1
  target_group_arns = [aws_lb_target_group.myLB_TG.arn]
  # https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on#usage
  depends_on = [aws_lb_target_group.myLB_TG]

  launch_template {
    id      = aws_launch_template.myLT.id
    version = "$Latest"
  }
}
