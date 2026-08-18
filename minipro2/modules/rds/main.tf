#
# RDS Aurora MySQL Cluster 생성
#
# 생성 순서 (의존성 중요):
# 1. DB Subnet Group 생성
# 2. RDS Cluster 생성    (DB Subnet Group 선행 필요)
# 3. RDS Cluster Instance1 생성 (Cluster 선행 필요)
# 4. RDS Cluster Instance2 생성 (Instance1 선행 필요)
#

# 1. DB Subnet Group 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group#example-usage
resource "aws_db_subnet_group" "myDBSubnetGroup" {
  name       = "mydbsubnetgroup"
  subnet_ids = var.subnet_ids
  tags       = var.db_subnet_group_tag
}

# 2. RDS Cluster 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster#example-usage
resource "aws_rds_cluster" "myDBCluster" {
  cluster_identifier     = "mydbcluster"
  engine                 = "aurora-mysql"
  database_name          = "mydb"
  master_username        = var.db_username
  master_password        = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.myDBSubnetGroup.name
  vpc_security_group_ids = [var.db_sg_id]
  skip_final_snapshot    = true

  depends_on = [aws_db_subnet_group.myDBSubnetGroup]
}

# 3. RDS Cluster Instance1 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance#example-usage
resource "aws_rds_cluster_instance" "myDBInstance1" {
  identifier         = "mydbinstance-1"
  cluster_identifier = aws_rds_cluster.myDBCluster.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.myDBCluster.engine

  depends_on = [aws_rds_cluster.myDBCluster]
}

# 4. RDS Cluster Instance2 생성
resource "aws_rds_cluster_instance" "myDBInstance2" {
  identifier         = "mydbinstance-2"
  cluster_identifier = aws_rds_cluster.myDBCluster.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.myDBCluster.engine

  depends_on = [aws_rds_cluster_instance.myDBInstance1]
}
