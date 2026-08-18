variable "region" {
  default = "ap-northeast-2"
}

variable "vpc_cidr" {
  default = "190.160.0.0/16"
}

variable "subnet_cidr" {
  default = ["190.160.1.0/24", "190.160.2.0/24", "190.160.3.0/24", "190.160.4.0/24"]
}

variable "vpc_tag" {
  default = {
        Name = "Main"
        Location = "Seoul"
    }
}

# variable "asz" {
#   default = ["ap-northeast-2a","ap-northeast-2b","ap-northeast-2c", "ap-northeast-2d"]
#   type = list
# }

data "aws_availability_zones" "azs" {}

