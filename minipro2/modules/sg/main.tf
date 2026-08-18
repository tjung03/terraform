#
# Security Group 생성
#
# 생성 순서:
# 1. ALB SG  - 80/tcp inbound (from internet)
# 2. EC2 SG  - 80/tcp inbound (from ALB SG only)
# 3. DB SG   - 3306/tcp inbound (from EC2 SG only)
#

# 1. ALB SG
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#example-usage
resource "aws_security_group" "myALB_SG" {
  name        = "myALB_SG"
  description = "Allow 80/tcp inbound and all outbound"
  vpc_id      = var.vpc_id
  tags        = var.alb_sg_tag
}

resource "aws_vpc_security_group_ingress_rule" "alb_80" {
  security_group_id = aws_security_group.myALB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.myALB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# 2. EC2 SG (ALB SG에서만 허용)
resource "aws_security_group" "myEC2_SG" {
  name        = "myEC2_SG"
  description = "Allow 80/tcp from ALB SG and all outbound"
  vpc_id      = var.vpc_id
  tags        = var.ec2_sg_tag
}

resource "aws_vpc_security_group_ingress_rule" "ec2_from_alb" {
  security_group_id            = aws_security_group.myEC2_SG.id
  referenced_security_group_id = aws_security_group.myALB_SG.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "ec2_all" {
  security_group_id = aws_security_group.myEC2_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# 3. DB SG (EC2 SG에서만 허용)
resource "aws_security_group" "myDB_SG" {
  name        = "myDB_SG"
  description = "Allow 3306/tcp from EC2 SG"
  vpc_id      = var.vpc_id
  tags        = var.db_sg_tag
}

resource "aws_vpc_security_group_ingress_rule" "db_from_ec2" {
  security_group_id            = aws_security_group.myDB_SG.id
  referenced_security_group_id = aws_security_group.myEC2_SG.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_egress_rule" "db_all" {
  security_group_id = aws_security_group.myDB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
