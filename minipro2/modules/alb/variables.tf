variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Public Subnet IDs for ALB"
}

variable "alb_sg_id" {
  type        = string
  description = "ALB Security Group ID"
}

variable "alb_tag" {
  default = {
    Name = "myALB"
  }
}
