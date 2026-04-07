terraform {
    required_providers {
        aws = {
            source =  "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "eu-south-2"
}

# 1. Create the "Topic" (the Alarm Channel)
resource "aws_sns_topic" "website_health_alerts" {
    name = "website_health_alerts"
}

# 2. Create the "Subscription" (Your Email)
resource "aws_sns_topic_subscription" "email_alert" {
    topic_arn = aws_sns_topic.website_health_alerts.arn
    protocol = "email"
    endpoint = "yihan2255@gmail.com"
}

# 3. The "identity card" (The Role Itself) 
resource "aws_iam_role" "lambda_role" {
    name = "webstite_monitor_lambda_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })
}

# 4. The "Permission list" (What the Role is allowed to do)
resource "aws_iam_role_policy" "lambda_policy" {
    name = "lambda_monitoring_policy"
    role = aws_iam_role.lambda_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                # Permission to create logs so we can see if it is working
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogsEvents"
                ]
                Effect = "Allow"
                Resource = "arn:aws:logs:*:*:*"
            },
            {
                # Permission to Publish to the SNS topic we made in Step 3
                Action = "sns:Publish"
                Effect = "Allow"
                Resource = aws_sns_topic.website_health_alerts.arn
            }
        ]
    })
}

# 5. Zip the python code
data "archive_file" "lambda_zip" {
    type = "zip"
    source_file = "monitor.py"
    output_path = "monitor.zip"
}

# 6. Create the Lambda Function
resource "aws_lambda_function" "site_monitor" {
    filename = "monitor.zip"
    function_name = "website_health_check"
    role = "aws_iam_role.lambda_role.arn"
    handler = "monitor.lambda_handler"
    runtime = "python3.9"

    environment {
        variables = {
            SNS_TOPIC_ARN = aws_sns_topic.website_health_alerts.arn
            SITE_URL = var.target_url
        }
    }

    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# 7. The "Alarm Clock" (The Rule)
resource "aws_cloudwatch_event_rule" "every_interval" {
    name = "check_website_timer"
    description = "Triggers Lambda based on variable interval"
    schedule_expression = "rate(${var.check_interval} minutes)"
}

# 8. Pointing the Clock at the Lambda (The Target)
resource "aws_cloudwatch_event_target" "check_website_callback" {
    rule = aws_cloudwatch_event_rule.every_interval.name
    target_id = "lambda"
    arn = aws_lambda_function.site_monitor.arn
}

# 9. Giving Permission (The "Open Door")
# EventBridge needs explicit permission to "knock on the door" of Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.site_monitor.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_interval.arn
}


