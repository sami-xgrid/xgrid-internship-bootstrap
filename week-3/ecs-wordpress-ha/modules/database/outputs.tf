output "db_endpoint" { value = aws_db_instance.db.endpoint }
output "db_host_arn" { value = aws_ssm_parameter.db_host.arn }
output "db_user_arn" { value = aws_ssm_parameter.db_user.arn }
output "db_password_arn" { value = aws_ssm_parameter.db_password.arn }
