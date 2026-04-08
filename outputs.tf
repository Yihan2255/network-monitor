output "sns_topic_arn" {
  description = "The ARN of the SNS topic for alerts"
  value       = aws_sns_topic.website_health_alerts.arn
}

output "lambda_function_name" {
  description = "The name of the monitoring Lambda function"
  value       = aws_lambda_function.site_monitor.function_name
}

output "monitoring_target_url" {
  description = "The URL being monitored"
  value       = var.target_url
}