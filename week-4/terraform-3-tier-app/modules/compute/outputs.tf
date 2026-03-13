output "frontend_public_ip" {
  description = "Public IP of the Frontend instance"
  value       = aws_instance.frontend.public_ip
}

output "backend_private_ip" {
  description = "Private IP of the Backend instance"
  value       = aws_instance.backend.private_ip
}

output "frontend_instance_id" {
  value = aws_instance.frontend.id
}
