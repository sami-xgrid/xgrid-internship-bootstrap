variable "alert_email" {
  description = "Email address for receiving CloudWatch SNS alerts"
  type        = string
}

variable "sns_topic_name" {
  description = "Name of the SNS topic for alerts"
  type        = string
  default     = "wordpress-slo-alerts"
}

variable "comparison_operator" {
  description = "Comparison operator for CloudWatch alarms"
  type        = string
  default     = "GreaterThanThreshold"
}

variable "cpu_period" {
  description = "Period (in seconds) for CPU utilization alarms"
  type        = number
  default     = 60
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for ECS Cluster alarm"
  type        = number
  default     = 80
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the ALB Target Group"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  type        = string
}

variable "rds_instance_id" {
  description = "Identifier of the RDS instance"
  type        = string
}
