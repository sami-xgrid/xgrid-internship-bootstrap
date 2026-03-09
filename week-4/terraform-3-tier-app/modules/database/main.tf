resource "aws_db_subnet_group" "aurora" {
  name       = "${var.environment}-aurora-subnet-group"
  subnet_ids = var.db_subnet_group_ids
}

# Generate a random initial password (ignored after IAM auth setup)
resource "random_password" "db_master" {
  length  = 16
  special = false
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier                  = "${var.environment}-aurora-cluster"
  engine                              = var.db_engine
  engine_mode                         = var.db_engine_mode
  engine_version                      = var.db_engine_version
  database_name                       = var.db_name
  master_username                     = var.db_user
  master_password                     = random_password.db_master.result
  db_subnet_group_name                = aws_db_subnet_group.aurora.name
  vpc_security_group_ids              = [var.db_security_group]
  skip_final_snapshot                 = true
  iam_database_authentication_enabled = true

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
}
