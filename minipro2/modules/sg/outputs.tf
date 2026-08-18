output "alb_sg_id" {
  value = aws_security_group.myALB_SG.id
}

output "ec2_sg_id" {
  value = aws_security_group.myEC2_SG.id
}

output "db_sg_id" {
  value = aws_security_group.myDB_SG.id
}
