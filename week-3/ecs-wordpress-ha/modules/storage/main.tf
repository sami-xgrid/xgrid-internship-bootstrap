resource "aws_security_group" "efs_sg" {
  name        = "wordpress-efs-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.ecs_sg_id]
  }
}

resource "aws_efs_file_system" "efs" {
  creation_token = "wordpress-efs"
  encrypted      = true
}

resource "aws_efs_mount_target" "efs_mount" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}