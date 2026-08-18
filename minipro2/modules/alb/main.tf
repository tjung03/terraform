#
# ALB 생성
#
# 생성 순서 (순서 중요):
# 1. TG 생성
# 2. LB 생성
# 3. LB Listener 생성
# 4. LB Listener Rule 생성
#

# 1. TG 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#example-usage
resource "aws_lb_target_group" "myTG" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# 2. LB 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#application-load-balancer
resource "aws_lb" "myALB" {
  name               = "myALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.subnet_ids
  tags               = var.alb_tag
}

# 3. LB Listener 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener#forward-action
resource "aws_lb_listener" "myALB_Listener" {
  load_balancer_arn = aws_lb.myALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myTG.arn
  }
}

# 4. LB Listener Rule 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#example-usage
resource "aws_lb_listener_rule" "myALB_Listener_Rule" {
  listener_arn = aws_lb_listener.myALB_Listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myTG.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
