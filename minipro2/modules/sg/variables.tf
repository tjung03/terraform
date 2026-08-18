variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "alb_sg_tag" {
  default = {
    Name = "myALB_SG"
  }
}

variable "ec2_sg_tag" {
  default = {
    Name = "myEC2_SG"
  }
}

variable "db_sg_tag" {
  default = {
    Name = "myDB_SG"
  }
}
