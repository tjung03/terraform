output "public_IP" {
  value = aws_instance.myinstance.public_ip
  description = "My EC2 Public IP"
}
