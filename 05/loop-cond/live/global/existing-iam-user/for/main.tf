provider "aws" {
  region = "ap-northeast-2"
}

variable "names" {
  default = ["neo", "trinity", "morpheus"]
}

output "upper_names" {
  value = [for name in var.names: upper(name)]
}

#---------------------------------------------

variable "here_thousand_faces" {
  default = {
    neo = "hero"
    trinity = "love interest"
    morpheus = "mentor"
  }
}

output "bios" {
  value = [for name,role in var.here_thousand_faces: "${name}: ${role}"]
}

output "bios2" {
  value = {for name,role in var.here_thousand_faces: name => role}
}

