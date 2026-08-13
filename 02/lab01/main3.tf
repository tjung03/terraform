########################################
# 작업 계획:
# 1. NAT Gateway 생성(PublicSN)
# 2. Private Subnet 생성
# 3. Private Routing Table 생성 및 연결
# 4. SG 생성
# 5. EC2 생성
########################################
# 1. NAT Gateway 생성(PublicSN)
# * EIP 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip#example-usage
resource "aws_eip" "myEIP" {
  domain     = "vpc"

  tags = {
    Name = "myEIP"
  }
}

# * public Subnet에 NAT Gateway 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway#example-usage
resource "aws_nat_gateway" "myNAT-GW" {
  allocation_id = aws_eip.myEIP.id
  subnet_id     = aws_subnet.myPubSN.id

  tags = {
    Name = "myNAT-GW"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.myIGW]
}

# 2. Private Subnet 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet#basic-usage
# * 새로 생성된 myVPC에 놓아야 한다.
resource "aws_subnet" "myPriSN" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "myPriSN"
  }
}

# 3. Private Routing Table 생성 및 연결
# myPriRT 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table#basic-example
resource "aws_route_table" "myPriRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.myNAT-GW.id
  }

  tags = {
    Name = "myPriRT"
  }
}

# myPriRT 연결 - myPriSN
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association#example-usage
resource "aws_route_table_association" "myPriRTassoc" {
  subnet_id      = aws_subnet.myPriSN.id
  route_table_id = aws_route_table.myPriRT.id
}

# 4. SG 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#example-usage
# * SG(22/tcp, 80/tcp, 443/tcp)
resource "aws_security_group" "mySG2" {
  name        = "mySG2"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySG2"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_pri22" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_pri80" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_pri443" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_priall" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# 5. EC2 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#example-usage
# * 새로 생성된 SG를 사용
# * mykeypair
# * 새로 생성된 myPriSN에 놓아야 한다.
# * user_data -> user_data_replace_on_change = true
resource "aws_instance" "MyPriEC2" {
  ami           = "ami-048f644e868baa0e8"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.mySG2.id]
  key_name      = "mykeypair"
  subnet_id     = aws_subnet.myPriSN.id

  user_data_replace_on_change = true
  user_data = <<-EOF
    #!/bin/bash
    dnf -y install httpd mod_ssl
    echo "My EC2 01" > /var/www/html/index.html
    systemctl enable --now httpd 
    EOF

  tags = {
    Name = "MyPriEC2"
  }
}

