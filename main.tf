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

