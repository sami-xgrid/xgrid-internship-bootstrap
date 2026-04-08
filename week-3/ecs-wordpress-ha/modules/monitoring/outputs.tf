output "alb_5xx_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for ALB 5XX errors"
  value       = aws_cloudwatch_metric_alarm.high_5xx_errors.arn
}

output "alb_latency_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for ALB latency"
  value       = aws_cloudwatch_metric_alarm.high_latency.arn
}

output "ecs_cpu_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for ECS CPU utilization"
  value       = aws_cloudwatch_metric_alarm.ecs_cpu_high.arn
}

output "rds_cpu_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for RDS CPU utilization"
  value       = aws_cloudwatch_metric_alarm.rds_cpu_high.arn

}

output "composite_alarm_arn" {
  description = "The ARN of the CloudWatch composite alarm for overall SLO breaches"
  value       = aws_cloudwatch_composite_alarm.system_saturation.arn

}
