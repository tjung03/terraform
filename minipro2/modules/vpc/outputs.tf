output "vpc_id" {
  value = aws_vpc.myVPC.id
}

output "public_subnet_ids" {
  value = [aws_subnet.myPubSN1.id, aws_subnet.myPubSN2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.myPriSN1.id, aws_subnet.myPriSN2.id]
}
