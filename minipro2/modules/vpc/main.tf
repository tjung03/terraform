#
# VPC + IGW + Subnet + Route Table 생성
#
# 생성 순서:
# 1. VPC 생성
# 2. IGW 생성
# 3. Public Subnet x2 생성 (ap-northeast-2a, ap-northeast-2c)
# 4. Private Subnet x2 생성 (ap-northeast-2a, ap-northeast-2c)
# 5. Public Route Table 생성 (0.0.0.0/0 → IGW)
# 6. Private Route Table 생성
# 7. Route Table Association
#

# 1. VPC 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#example-usage
resource "aws_vpc" "myVPC" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags                 = var.vpc_tag
}

# 2. IGW 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway#example-usage
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id
  tags   = var.igw_tag
}

# 3. Public Subnet x2 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet#example-usage
resource "aws_subnet" "myPubSN1" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = var.pub_sn1_cidr
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags                    = var.pub_sn1_tag
}

resource "aws_subnet" "myPubSN2" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = var.pub_sn2_cidr
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true
  tags                    = var.pub_sn2_tag
}

# 4. Private Subnet x2 생성
resource "aws_subnet" "myPriSN1" {
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = var.pri_sn1_cidr
  availability_zone = "ap-northeast-2a"
  tags              = var.pri_sn1_tag
}

resource "aws_subnet" "myPriSN2" {
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = var.pri_sn2_cidr
  availability_zone = "ap-northeast-2c"
  tags              = var.pri_sn2_tag
}

# 5. Public Route Table 생성 (Default Route → IGW)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table#example-usage
resource "aws_route_table" "myPubRT" {
  vpc_id = aws_vpc.myVPC.id
  tags   = var.pub_rt_tag

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }
}

# 6. Private Route Table 생성
resource "aws_route_table" "myPriRT" {
  vpc_id = aws_vpc.myVPC.id
  tags   = var.pri_rt_tag
}

# 7. Route Table Association
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association#example-usage
resource "aws_route_table_association" "myPubRTassoc1" {
  subnet_id      = aws_subnet.myPubSN1.id
  route_table_id = aws_route_table.myPubRT.id
}

resource "aws_route_table_association" "myPubRTassoc2" {
  subnet_id      = aws_subnet.myPubSN2.id
  route_table_id = aws_route_table.myPubRT.id
}

resource "aws_route_table_association" "myPriRTassoc1" {
  subnet_id      = aws_subnet.myPriSN1.id
  route_table_id = aws_route_table.myPriRT.id
}

resource "aws_route_table_association" "myPriRTassoc2" {
  subnet_id      = aws_subnet.myPriSN2.id
  route_table_id = aws_route_table.myPriRT.id
}
