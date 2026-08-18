output "arns" {
  value = values(aws_iam_user.createuser)[*].arn
}
