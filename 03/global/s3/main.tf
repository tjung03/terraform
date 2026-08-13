provider "aws" {
  region = "us-east-2"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#example-usage
resource "aws_s3_bucket" "mybucket" {
  bucket = "bucket-jth-1103"
  force_destroy = true
  
  tags = {
    Name = "mybucket"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table#example-usage
resource "aws_dynamodb_table" "mylocks" {
  name           = "terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-locks"
  }
}

# s3_bucket_arn = "arn:aws:s3:::bucket-jth-1103"
output "s3_bucket_arn" {
  value = aws_s3_bucket.mybucket.arn
}

# dynamodb_table_name = "terraform-locks"
output "dynamodb_table_name" {
  value = aws_dynamodb_table.mylocks.name
}
