terraform {
  backend "s3" {
    bucket = "bucket-jth-1103"
    key    = "terraform.tfstate"
    region = "us-east-2"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-2"
}

# MySQL DB Instance 설정
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#example-usage
resource "aws_db_instance" "myDB" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.dbuser
  password             = "password"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}


#
# terraform state list
# terraform state show aws_db_instance.myDB
#

# DB IP/Port
output "dbIP" {
  value = aws_db_instance.myDB.address
}
output "dbPort" {
  value = aws_db_instance.myDB.port
}

# DB User/Password
# DB/Table

