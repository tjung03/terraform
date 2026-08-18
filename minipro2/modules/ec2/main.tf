#
# EC2(ASG) 생성
#
# 생성 순서 (순서 중요):
# * ALB(TG ARN), RDS(endpoint, port) 선행 생성 필요
# 1. AMI 조회
# 2. LT 생성 (httpd, php 설치 / DB 접속정보 주입)
# 3. ASG 생성
#

# 1. AMI 조회
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

# 2. LT 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#example-usage
resource "aws_launch_template" "myLT" {
  name                   = "myLT"
  image_id               = data.aws_ami.amz2023ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.ec2_sg_id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_endpoint = var.db_endpoint
    db_port     = var.db_port
  }))

  tag_specifications {
    resource_type = "instance"
    tags          = var.ec2_tag
  }
}

# 3. ASG 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#with-latest-version-of-launch-template
resource "aws_autoscaling_group" "myASG" {
  vpc_zone_identifier = var.subnet_ids
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1

  # ALB TG에 ASG 등록
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#target_group_arns-1
  target_group_arns = [var.target_group_arn]
  depends_on        = [aws_launch_template.myLT]

  launch_template {
    id      = aws_launch_template.myLT.id
    version = "$Latest"
  }
}
