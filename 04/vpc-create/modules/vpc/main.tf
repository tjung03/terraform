# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#example-usage
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags             = var.vpc_tag
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet#example-usage
resource "aws_subnet" "main" {
  vpc_id     = var.vpc_id
  cidr_block = var.subnet_cidr
  tags       = var.subnet_tag
}

