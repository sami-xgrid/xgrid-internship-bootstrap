resource "aws_security_group" "ec2_compute_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for ${var.instance_name}"

    # Inbound SSH
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Inbound HTTP
    ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Outbound traffic
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_compute_sg.id]
  key_name = var.key_pair_name

    tags = {
        Name = var.instance_name
    }
}