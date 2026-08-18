variable "subnet_ids" {
  type        = list(string)
  description = "Private Subnet IDs for DB Cluster"
}

variable "db_sg_id" {
  type        = string
  description = "DB Security Group ID"
}

variable "db_username" {
  type        = string
  description = "DB master username"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "DB master password"
  sensitive   = true
}

variable "db_instance_class" {
  default = "db.r5.large"
}

variable "db_subnet_group_tag" {
  default = {
    Name = "myDBSubnetGroup"
  }
}
