# API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "lambda-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = [
      "http://localhost:8080", 
      "https://quantifyjiujitsu.com", 
      "https://www.quantifyjiujitsu.com"
    ]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["content-type", "authorization", "x-api-key", "x-amz-date", "x-amz-security-token"]
    expose_headers = ["content-length", "date"]
    allow_credentials = true
    max_age       = 3600
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.api_lambda.invoke_arn
}

# Define specific routes instead of catch-all proxy

# Authentication routes
resource "aws_apigatewayv2_route" "signin" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "POST /signin"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "google_signin" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "POST /google-signin"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "signup" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "POST /signup"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "verify_email" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /verify-email"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "forgot_password" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /forgot-password"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "reset_password" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /reset-password"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "refresh_token" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /refresh-token"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Content routes
resource "aws_apigatewayv2_route" "search" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /search"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "proxy_image" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /proxy-image"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Routes with path parameters
resource "aws_apigatewayv2_route" "view_post" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /viewpost/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "view_profile" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /viewprofile/{username}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "edit_profile" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "PUT /editprofile/{user_id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "new_post" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /newpost/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "edit_post" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "PUT /editpost/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "delete_post" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "DELETE /deletepost/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "apigw" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# API Gateway Custom Domain Names
resource "aws_apigatewayv2_domain_name" "api" {
  domain_name = "api.quantifyjiujitsu.com"
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api_cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_domain_name" "api_dev" {
  domain_name = "api-dev.quantifyjiujitsu.com"
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api_dev_cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_domain_name" "api_staging" {
  domain_name = "api-staging.quantifyjiujitsu.com"
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api_staging_cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_stage" "prod_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "prod"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
    detailed_metrics_enabled = true
  }

  # The stage depends on all routes being created
  depends_on = [
    aws_apigatewayv2_route.signin,
    aws_apigatewayv2_route.google_signin,
    aws_apigatewayv2_route.signup,
    aws_apigatewayv2_route.verify_email,
    aws_apigatewayv2_route.forgot_password,
    aws_apigatewayv2_route.reset_password,
    aws_apigatewayv2_route.refresh_token,
    aws_apigatewayv2_route.search,
    aws_apigatewayv2_route.proxy_image,
    aws_apigatewayv2_route.view_post,
    aws_apigatewayv2_route.view_profile,
    aws_apigatewayv2_route.edit_profile,
    aws_apigatewayv2_route.new_post,
    aws_apigatewayv2_route.edit_post,
    aws_apigatewayv2_route.delete_post
  ]

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.prod_logs.arn
    format = jsonencode({
      requestId       = "$context.requestId"
      ip              = "$context.identity.sourceIp"
      requestTime     = "$context.requestTime"
      httpMethod      = "$context.httpMethod"
      routeKey        = "$context.routeKey"
      status          = "$context.status"
      responseLength  = "$context.responseLength"
      responseLatency = "$context.responseLatency"
      errorMessage    = "$context.error.message"
    })
  }
}

resource "aws_apigatewayv2_stage" "dev_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "dev"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 50
    throttling_rate_limit  = 25
    detailed_metrics_enabled = true
  }
  
  # The stage depends on all routes being created
  depends_on = [
    aws_apigatewayv2_route.signin,
    aws_apigatewayv2_route.google_signin,
    aws_apigatewayv2_route.signup,
    aws_apigatewayv2_route.verify_email,
    aws_apigatewayv2_route.forgot_password,
    aws_apigatewayv2_route.reset_password,
    aws_apigatewayv2_route.refresh_token,
    aws_apigatewayv2_route.search,
    aws_apigatewayv2_route.proxy_image,
    aws_apigatewayv2_route.view_post,
    aws_apigatewayv2_route.view_profile,
    aws_apigatewayv2_route.edit_profile,
    aws_apigatewayv2_route.new_post,
    aws_apigatewayv2_route.edit_post,
    aws_apigatewayv2_route.delete_post
  ]

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.dev_logs.arn
    format = jsonencode({
      requestId       = "$context.requestId"
      ip              = "$context.identity.sourceIp"
      requestTime     = "$context.requestTime"
      httpMethod      = "$context.httpMethod"
      routeKey        = "$context.routeKey"
      status          = "$context.status"
      responseLength  = "$context.responseLength"
      responseLatency = "$context.responseLatency"
      errorMessage    = "$context.error.message"
    })
  }
}

resource "aws_apigatewayv2_stage" "staging_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "staging"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 75
    throttling_rate_limit  = 40
    detailed_metrics_enabled = true
  }
  
  # The stage depends on all routes being created
  depends_on = [
    aws_apigatewayv2_route.signin,
    aws_apigatewayv2_route.google_signin,
    aws_apigatewayv2_route.signup,
    aws_apigatewayv2_route.verify_email,
    aws_apigatewayv2_route.forgot_password,
    aws_apigatewayv2_route.reset_password,
    aws_apigatewayv2_route.refresh_token,
    aws_apigatewayv2_route.search,
    aws_apigatewayv2_route.proxy_image,
    aws_apigatewayv2_route.view_post,
    aws_apigatewayv2_route.view_profile,
    aws_apigatewayv2_route.edit_profile,
    aws_apigatewayv2_route.new_post,
    aws_apigatewayv2_route.edit_post,
    aws_apigatewayv2_route.delete_post
  ]

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.staging_logs.arn
    format = jsonencode({
      requestId       = "$context.requestId"
      ip              = "$context.identity.sourceIp"
      requestTime     = "$context.requestTime"
      httpMethod      = "$context.httpMethod"
      routeKey        = "$context.routeKey"
      status          = "$context.status"
      responseLength  = "$context.responseLength"
      responseLatency = "$context.responseLatency"
      errorMessage    = "$context.error.message"
    })
  }
}

resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id      = aws_apigatewayv2_api.http_api.id
  domain_name = aws_apigatewayv2_domain_name.api.domain_name
  stage       = aws_apigatewayv2_stage.prod_stage.name
}

resource "aws_apigatewayv2_api_mapping" "api_dev_mapping" {
  api_id      = aws_apigatewayv2_api.http_api.id
  domain_name = aws_apigatewayv2_domain_name.api_dev.domain_name
  stage       = aws_apigatewayv2_stage.dev_stage.name
}

resource "aws_apigatewayv2_api_mapping" "api_staging_mapping" {
  api_id      = aws_apigatewayv2_api.http_api.id
  domain_name = aws_apigatewayv2_domain_name.api_staging.domain_name
  stage       = aws_apigatewayv2_stage.staging_stage.name
}
