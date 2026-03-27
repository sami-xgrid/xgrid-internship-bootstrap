# ------------------------------------------------------------------------------
# 1. SNS Notification Hub (Least Privilege: Only CloudWatch can publish)
# ------------------------------------------------------------------------------
resource "aws_sns_topic" "alerts" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.alerts.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudwatch.amazonaws.com" }
      Action    = "sns:Publish"
      Resource  = aws_sns_topic.alerts.arn
    }]
  })
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

data "aws_region" "current" {}

# ------------------------------------------------------------------------------
# 2. SLO 1: Error Rate (ALB 5XX Errors)
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "high_5xx_errors" {
  alarm_name          = "slo-wordpress-high-5xx-errors"
  comparison_operator = var.comparison_operator
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300 
  statistic           = "Sum"
  threshold           = 5 
  alarm_description   = "SLO: Error Rate exceeded threshold."
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }
}

# ------------------------------------------------------------------------------
# 3. SLO 2: Latency (ALB Target Response Time)
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "slo-wordpress-high-latency"
  comparison_operator = var.comparison_operator
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60    
  extended_statistic  = "p95" 
  threshold           = 0.5   
  alarm_description   = "SLO: 95th percentile latency > 500ms."
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }
}

# ------------------------------------------------------------------------------
# 4. Saturation Metrics (To be used in Composite Alarm)
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "slo-wordpress-ecs-cpu-high"
  comparison_operator = var.comparison_operator
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cpu_period
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "ECS Cluster CPU > 80%"

  dimensions = {
    ClusterName = var.ecs_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "slo-wordpress-rds-cpu-high"
  comparison_operator = var.comparison_operator
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "RDS Instance CPU > 80%"

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}

# ------------------------------------------------------------------------------
# 5. SLO 3: Composite Alarm (System-wide Saturation)
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_composite_alarm" "system_saturation" {
  alarm_name        = "slo-wordpress-system-saturation"
  alarm_description = "SLO: Both ECS and RDS are experiencing >80% CPU saturation."
  alarm_actions     = [aws_sns_topic.alerts.arn]

  # ALARM triggers ONLY if both ECS AND RDS are saturated
  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.ecs_cpu_high.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.rds_cpu_high.alarm_name})"
}

# ------------------------------------------------------------------------------
# 6. CloudWatch Dashboard (SLO Visualization)
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "WordPress-SLO-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2
        properties = {
          markdown = "# 📊 WordPress Infrastructure SLO Dashboard\nMonitoring Latency, Error Rates, and Resource Saturation for the HA WordPress deployment."
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 12
        height = 6
        properties = {
          view    = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix]
          ]
          region = data.aws_region.current.name
          title  = "SLO: Error Rate (5XX Counts)"
          period = 300
          yAxis  = { left = { min = 0 } }
          annotations = {
            horizontal = [{ color = "#d13212", label = "SLO Breach Threshold", value = 5 }]
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 2
        width  = 12
        height = 6
        properties = {
          view    = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix, { stat = "p95" }]
          ]
          region = data.aws_region.current.name
          title  = "SLO: P95 Latency (Response Time)"
          period = 60
          yAxis  = { left = { min = 0 } }
          annotations = {
            horizontal = [{ color = "#d13212", label = "SLO Breach Threshold (500ms)", value = 0.5 }]
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 24
        height = 6
        properties = {
          view    = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name],
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id]
          ]
          region = data.aws_region.current.name
          title  = "SLO: System Saturation (CPU %)"
          period = 60
          yAxis  = { left = { min = 0, max = 100 } }
          annotations = {
            horizontal = [{ color = "#d13212", label = "Critical Saturation", value = 80 }]
          }
        }
      }
    ]
  })
}
