#
# 3 Tier Web-DB 서버 구축
# ELB(ALB) - TG(ASG(EC2 x 2)) - DB Cluster(DB x 2)
#
# 생성 순서:
# 1. vpc  - VPC, IGW, Subnet, Route Table
# 2. sg   - ALB SG, EC2 SG, DB SG
# 3. alb  - TG, ALB, Listener, Listener Rule
# 4. rds  - DB Subnet Group, Cluster, Instance x2
# 5. ec2  - Launch Template, ASG
#           * alb(TG), rds(endpoint) 선행 생성 필요
#

provider "aws" {
  region = "ap-northeast-2"
}

# 1. VPC 생성
module "myvpc" {
  source = "../modules/vpc"
}

# 2. SG 생성
module "mysg" {
  source = "../modules/sg"

  vpc_id = module.myvpc.vpc_id
}

# 3. ALB 생성
module "myalb" {
  source = "../modules/alb"

  vpc_id     = module.myvpc.vpc_id
  subnet_ids = module.myvpc.public_subnet_ids
  alb_sg_id  = module.mysg.alb_sg_id
}

# 4. RDS 생성
#    * EC2(ASG)보다 반드시 먼저 생성되어야 함
module "myrds" {
  source = "../modules/rds"

  subnet_ids  = module.myvpc.private_subnet_ids
  db_sg_id    = module.mysg.db_sg_id
  db_username = var.db_username
  db_password = var.db_password
}

# 5. EC2(ASG) 생성
#    * alb(TG ARN), rds(endpoint, port) 선행 생성 필요
module "myec2" {
  source = "../modules/ec2"

  subnet_ids       = module.myvpc.public_subnet_ids
  ec2_sg_id        = module.mysg.ec2_sg_id
  target_group_arn = module.myalb.target_group_arn
  db_endpoint      = module.myrds.db_endpoint
  db_port          = module.myrds.db_port

  depends_on = [module.myalb, module.myrds]
}
