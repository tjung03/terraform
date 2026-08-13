variable "security_group_name" {
  description = "My SG Name"
  type = string
  default = "allow_8080"
}

variable "server_port" {
  description = "My Server Port"
  type = number
  default = 8080
}



