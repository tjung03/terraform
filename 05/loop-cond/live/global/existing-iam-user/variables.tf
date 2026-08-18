variable "user_names" {
  default = ["red", "blue", "green"]
  type = list(string)
  description = "Create IAM users with these names"
}
