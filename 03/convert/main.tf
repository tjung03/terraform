terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# =========================================================
# Parameters
# =========================================================

# CloudFormation:
# KeyName:
#   Type: AWS::EC2::KeyPair::KeyName
variable "key_name" {
  type        = string
  description = "Name of an existing EC2 KeyPair"
}

# CloudFormation:
# LatestAmiId:
#   Type: AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>
#   Default: /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2
data "aws_ssm_parameter" "latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# !GetAZs
data "aws_availability_zones" "available" {
  state = "available"
}

# =========================================================
# VPC
# =========================================================

resource "aws_vpc" "myVPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "My-VPC"
  }
}

# =========================================================
# Internet Gateway
# =========================================================

resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "My-IGW"
  }
}

# Terraform에서는
# aws_internet_gateway의 vpc_id 설정으로
# CloudFormation의 VPCGatewayAttachment 역할까지 처리 가능

# =========================================================
# Public Route Table
# =========================================================

resource "aws_route_table" "myPublicRT" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "My-Public-RT"
  }
}

resource "aws_route" "myDefaultPublicRoute" {
  route_table_id         = aws_route_table.myPublicRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myIGW.id
}

# =========================================================
# Public Subnets
# =========================================================

resource "aws_subnet" "myPublicSN1" {
  vpc_id            = aws_vpc.myVPC.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.0.0/24"

  tags = {
    Name = "My-Public-SN-1"
  }
}

resource "aws_subnet" "myPublicSN2" {
  vpc_id            = aws_vpc.myVPC.id
  availability_zone = data.aws_availability_zones.available.names[2]
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "My-Public-SN-2"
  }
}

# =========================================================
# Route Table Association
# =========================================================

resource "aws_route_table_association" "myPublicSNRouteTableAssociation1" {
  subnet_id      = aws_subnet.myPublicSN1.id
  route_table_id = aws_route_table.myPublicRT.id
}

resource "aws_route_table_association" "myPublicSNRouteTableAssociation2" {
  subnet_id      = aws_subnet.myPublicSN2.id
  route_table_id = aws_route_table.myPublicRT.id
}

# =========================================================
# Security Group
# HTTP 80 / SSH 22
# =========================================================

resource "aws_security_group" "webSG" {
  name        = "WEBSG"
  description = "Enable HTTP access via port 80 and SSH access via port 22"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "WEBSG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "webSG_http" {
  security_group_id = aws_security_group.webSG.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "webSG_ssh" {
  security_group_id = aws_security_group.webSG.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "webSG_all" {
  security_group_id = aws_security_group.webSG.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# =========================================================
# EC2-1
# =========================================================

resource "aws_instance" "myEC21" {
  ami                    = data.aws_ssm_parameter.latest_ami.value
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.myPublicSN1.id
  vpc_security_group_ids = [aws_security_group.webSG.id]

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    hostname EC2-1
    yum install httpd -y
    service httpd start
    chkconfig httpd on
    echo "<h1>CloudNet@ EC2-1 Web Server</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "EC2-1"
  }
}

# =========================================================
# EC2-2
# =========================================================

resource "aws_instance" "myEC22" {
  ami                    = data.aws_ssm_parameter.latest_ami.value
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.myPublicSN2.id
  vpc_security_group_ids = [aws_security_group.webSG.id]

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    hostname ELB-EC2-2
    yum install httpd -y
    service httpd start
    chkconfig httpd on
    echo "<h1>CloudNet@ EC2-2 Web Server</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "EC2-2"
  }
}

# =========================================================
# Elastic IP - EC2-1
# =========================================================

resource "aws_eip" "myEIP1" {
  domain = "vpc"

  tags = {
    Name = "My-EIP-1"
  }
}

resource "aws_eip_association" "myEIP1Assoc" {
  instance_id   = aws_instance.myEC21.id
  allocation_id = aws_eip.myEIP1.id
}

# =========================================================
# Elastic IP - EC2-2
# =========================================================

resource "aws_eip" "myEIP2" {
  domain = "vpc"

  tags = {
    Name = "My-EIP-2"
  }
}

resource "aws_eip_association" "myEIP2Assoc" {
  instance_id   = aws_instance.myEC22.id
  allocation_id = aws_eip.myEIP2.id
}

# =========================================================
# ALB Target Group
# =========================================================

resource "aws_lb_target_group" "albTG" {
  name     = "My-ALB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myVPC.id
}

# CloudFormation의 Targets:
# - EC2-1
# - EC2-2
#
# Terraform에서는 target_group_attachment로 별도 연결

resource "aws_lb_target_group_attachment" "ec21" {
  target_group_arn = aws_lb_target_group.albTG.arn
  target_id        = aws_instance.myEC21.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec22" {
  target_group_arn = aws_lb_target_group.albTG.arn
  target_id        = aws_instance.myEC22.id
  port             = 80
}

# =========================================================
# Application Load Balancer
# =========================================================

resource "aws_lb" "applicationLoadBalancer" {
  name               = "My-ALB"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.webSG.id
  ]

  subnets = [
    aws_subnet.myPublicSN1.id,
    aws_subnet.myPublicSN2.id
  ]
}

# =========================================================
# ALB Listener
# =========================================================

resource "aws_lb_listener" "albListener" {
  load_balancer_arn = aws_lb.applicationLoadBalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.albTG.arn
  }
}

# =========================================================
# Outputs
# =========================================================

output "alb_dns_name" {
  value = aws_lb.applicationLoadBalancer.dns_name
}

output "ec2_1_eip" {
  value = aws_eip.myEIP1.public_ip
}

output "ec2_2_eip" {
  value = aws_eip.myEIP2.public_ip
}

