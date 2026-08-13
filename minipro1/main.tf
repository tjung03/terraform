#
# VPC(IGW) + Public Subnet(RT) + EC2(docker)
#
# VPC 생성
#   * VPC 생성
#   * IGW 생성과 VPC에 연결
# Public Subnet 생성
#   * PubSN 생성
#   * PubRT 생성과 PubSN 연결하고, Default Route 설정
# EC2 생성
#   * SG(all port)
#   * mykeypair
#   * EC2 생성
#     - user_data(docker 설치)


# 1. VPC 생성
#   1) VPC 생성
#     * enable_dns_hostnames
#     * cidr block: 10.0.0.0/16
resource "aws_vpc" "myVPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags                 = var.vpc_tag
}

#   2) IGW 생성과 VPC에 연결
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway#example-usage
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id
  tags   = var.igw_tag
}


# 2. ublic Subnet 생성
#   1) PubSN 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet#example-usage
resource "aws_subnet" "myPubSN" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"

  # * 퍼블릭 IPv4 주소 자동 할당: map_public_ip_on_launch
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet#map_public_ip_on_launch-1
  map_public_ip_on_launch = true

  tags = var.pubsn_tag
}

#   2) PubRT 생성과 PubSN 연결하고, Default Route 설정
#     * PubRT 생성과 Default Route 설정
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table#example-usage
resource "aws_route_table" "myPubRT" {
  vpc_id = aws_vpc.myVPC.id
  tags   = var.pubrt_tag

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }
}

#     * PubRT와 PubSN 연결
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association#example-usage
resource "aws_route_table_association" "myPubRTassoc" {
  subnet_id      = aws_subnet.myPubSN.id
  route_table_id = aws_route_table.myPubRT.id
}

# 3. EC2 생성
#   1) SG(all port)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#example-usage
# * all inbound/outbound traffic
resource "aws_security_group" "myEC2_SG" {
  name        = var.ec2_sg
  description = "Allow all inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id
  tags        = local.ec2_sg_tag
}

resource "aws_vpc_security_group_ingress_rule" "all" {
  security_group_id = aws_security_group.myEC2_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.myEC2_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#   2) mykeypair
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair#example-usage
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file(pathexpand("~/.ssh/mykeypair.pub"))
}

#   3) EC2 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#example-usage
#     * data source - aws ami
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

# subnet         : subnet_id
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#subnet_id-4
# mykeypair      : key_name
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#key_name-7
# security group : vpc_security_group_ids
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#vpc_security_group_ids-3
resource "aws_instance" "myEC2" {
  ami           = data.aws_ami.amz2023ami.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.myPubSN.id
  key_name = "mykeypair"
  vpc_security_group_ids = [aws_security_group.myEC2_SG.id]
  tags = var.ec2_tag

  # user_data(docker 설치)
  # * user_data_replace_on_change
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#user_data_replace_on_change-2
  user_data_replace_on_change = true
  # * user_data_base64
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#user_data_base64-2
  user_data_base64 = filebase64("user_data.sh")
  # user_data = filebase64('user_data.sh')

  # dev-server
  provisioner "local-exec" {
    command        = templatefile("linux-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ec2-user",
      identityfile = "~/.ssh/mykeypair"
    })
    interpreter    = ["bash", "-c"]
  }
}



