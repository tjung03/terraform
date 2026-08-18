output "db_endpoint" {
  value = aws_rds_cluster.myDBCluster.endpoint
}

output "db_port" {
  value = tostring(aws_rds_cluster.myDBCluster.port)
}
