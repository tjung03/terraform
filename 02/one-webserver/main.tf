# terraform/provider
provider "aws" {
  region = "us-east-2"
}

# EC2 Instance + Web Server 생성
# * SG(8080/tcp)
# * EC2 생성(user_data)
# -----------user_data-------------
# #!/bin/bash
# echo "Hello, World" > index.html
# nohup busybox httpd -f -p 8080 &
# ---------------------------------

# * SG(8080/tcp)
resource "aws_security_group" "allow_8080" {
  name        = "allow_8080"
  description = "Allow 8080/tcp inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_8080"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_web" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# * EC2 생성(SG 연결 & user_data)
resource "aws_instance" "myinstance" {
  ami           = "ami-0e5497a77ef21b5ac"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.allow_8080.id]

  user_data_replace_on_change = true
  user_data = <<-EOF
  #!/bin/bash
  echo "<h1>My Web</h1>" > index.html
  nohup busybox httpd -f -p 8080 &
  EOF

  tags = {
    Name = "myEC2"
  }
}

# https://chatgpt.com/?utm_source=google&utm_medium=paid_search&utm_campaign=GOOG_C_SEM_GBR_Core_CHT_BAU_ACQ_PER_MIX_ALL_APAC_KR_KO_120624&c_id=21990694068&c_agid=183521101147&c_crid=793872436049&c_kwid=kwd-2422136497622&c_ims=&c_pms=9196705&c_nw=g&c_dvc=c&gad_source=1&gad_campaignid=21990694068&gbraid=0AAAAA-I0E5feVoyf952gfeHWcxnVImMgV&gclid=EAIaIQobChMI7fzWraiGlAMVhoC5BR1wqDebEAAYASAAEgI9BvD_BwE&temporary-chat=true
