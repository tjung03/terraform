terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  # https://developer.hashicorp.com/terraform/language/backend/s3#example-configuration
  backend "s3" {
    bucket = "bucket-jth-1103"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"

    # dynamodb_table = "terraform-locks"
    use_lockfile = true
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#example-usage
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}



