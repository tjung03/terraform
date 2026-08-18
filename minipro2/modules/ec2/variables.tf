variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for ASG"
}

variable "ec2_sg_id" {
  type        = string
  description = "EC2 Security Group ID"
}

variable "target_group_arn" {
  type        = string
  description = "ALB Target Group ARN"
}

variable "db_endpoint" {
  type        = string
  description = "RDS DB Endpoint"
}

variable "db_port" {
  type        = string
  description = "RDS DB Port"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ec2_tag" {
  default = {
    Name = "myEC2"
  }
}
