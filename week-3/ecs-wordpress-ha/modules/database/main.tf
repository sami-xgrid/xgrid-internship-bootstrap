resource "aws_security_group" "rds_sg" {
  name        = "wordpress-rds-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ecs_sg_id]
  }
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "wordpress-db-subnet"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "db" {
  identifier             = "wordpress-ha-db"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "wordpressdb"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  multi_az               = true
  skip_final_snapshot    = true
}