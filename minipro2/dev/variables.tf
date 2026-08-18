variable "db_username" {
  type        = string
  description = "Enter DB master username:"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "Enter DB master password:"
  sensitive   = true
}
