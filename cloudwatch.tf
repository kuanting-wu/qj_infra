resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/lambda_rds"
  retention_in_days = 30  # Adjust retention period as needed
}

resource "aws_cloudwatch_log_metric_filter" "lambda_error_metric" {
  name           = "LambdaErrorMetric"
  log_group_name = aws_cloudwatch_log_group.lambda_log_group.name
  pattern        = "ERROR"

  metric_transformation {
    name      = "LambdaErrors"
    namespace = "MyApp/Lambda"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "LambdaErrorAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.lambda_error_metric.metric_transformation[0].name
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Triggers when Lambda logs 5+ errors in 5 minutes"
  alarm_actions       = [aws_sns_topic.lambda_alarm_sns.arn]  # Sends notification to SNS
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration_alarm" {
  alarm_name          = "LambdaDurationAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Average"
  threshold           = 3000  # 3000 ms = 3 seconds
  alarm_description   = "Triggers when Lambda execution time exceeds 3 seconds"
  alarm_actions       = [aws_sns_topic.lambda_alarm_sns.arn]
}

resource "aws_sns_topic" "lambda_alarm_sns" {
  name = "lambda_alarm_notifications"
}

resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.lambda_alarm_sns.arn
  protocol  = "email"
  endpoint  = "quentinwu0304@gmail.com"  # Replace with your email
}

resource "aws_cloudwatch_log_group" "prod_logs" {
  name              = "/aws/api-gateway/prod"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "dev_logs" {
  name              = "/aws/api-gateway/dev"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "staging_logs" {
  name              = "/aws/api-gateway/staging"
  retention_in_days = 7
}
