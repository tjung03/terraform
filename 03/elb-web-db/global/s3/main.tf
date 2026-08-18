provider "aws" {
  region = "us-east-2"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#example-usage
resource "aws_s3_bucket" "myTFState" {
  bucket = "bucket-jth-1103"
  force_destroy = true

  tags = {
    Name        = "myTFState"
  }
}

#
# terraform state list
# terraform state show aws_s3_bucket.myTFState
#
output "s3_bucket_arn" {
  value = aws_s3_bucket.myTFState.arn
}

