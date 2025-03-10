# Lambda function definition
resource "aws_lambda_function" "api_lambda" {
  function_name = "lambda_rds"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  s3_bucket     = aws_s3_bucket.backend_s3.bucket
  s3_key        = "lambda_code.zip"
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 10        # Increased timeout for network operations
  memory_size   = 256       # Increased memory for better performance

  # Lambda in private subnet with internet access via NAT Gateway
  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_az1.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
  
  environment {
    variables = {
      DB_HOST     = aws_db_instance.postgres_db.address
      DB_PORT     = aws_db_instance.postgres_db.port
      DB_NAME     = aws_db_instance.postgres_db.db_name
      DB_USER     = aws_db_instance.postgres_db.username
      SES_EMAIL_FROM = var.ses_email_from
    }
  }
  
  # Allow this to be updated without destroying
  lifecycle {
    ignore_changes = [
      environment, 
      vpc_config,
      s3_bucket,
      s3_key,
      handler,
      runtime
    ]
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.lambda_exec_policy_attachment,
    aws_iam_role_policy_attachment.lambda_vpc_policy_attachment
  ]
}

