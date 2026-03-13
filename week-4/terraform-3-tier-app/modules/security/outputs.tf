output "web_sg_id" {
  description = "The ID of the security group for the web tier"
  value       = aws_security_group.web.id
}

output "app_sg_id" {
  description = "The ID of the security group for the app tier"
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "The ID of the security group for the db tier"
  value       = aws_security_group.db.id
}

output "backend_instance_profile" {
  description = "The name of the IAM instance profile for backend EC2"
  value       = aws_iam_instance_profile.backend_profile.name
}

output "frontend_instance_profile" {
  description = "The name of the IAM instance profile for frontend EC2"
  value       = aws_iam_instance_profile.frontend_profile.name
}