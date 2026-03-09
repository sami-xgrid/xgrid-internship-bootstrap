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
