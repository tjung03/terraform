variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_tag" {
  default = {
    Name = "myVPC"
  }
}

variable "igw_tag" {
  default = {
    Name = "myIGW"
  }
}

variable "pub_sn1_cidr" {
  default = "10.0.1.0/24"
}

variable "pub_sn1_tag" {
  default = {
    Name = "myPubSN1"
  }
}

variable "pub_sn2_cidr" {
  default = "10.0.2.0/24"
}

variable "pub_sn2_tag" {
  default = {
    Name = "myPubSN2"
  }
}

variable "pri_sn1_cidr" {
  default = "10.0.3.0/24"
}

variable "pri_sn1_tag" {
  default = {
    Name = "myPriSN1"
  }
}

variable "pri_sn2_cidr" {
  default = "10.0.4.0/24"
}

variable "pri_sn2_tag" {
  default = {
    Name = "myPriSN2"
  }
}

variable "pub_rt_tag" {
  default = {
    Name = "myPubRT"
  }
}

variable "pri_rt_tag" {
  default = {
    Name = "myPriRT"
  }
}
