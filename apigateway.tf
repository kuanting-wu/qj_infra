# API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "lambda-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = [
      "http://localhost:8080",
      "http://localhost:8081",
      "http://localhost:3000",
      "https://quantifyjiujitsu.com", 
      "https://www.quantifyjiujitsu.com",
      "https://dev.quantifyjiujitsu.com",
      "https://staging.quantifyjiujitsu.com",
      "https://api-dev.quantifyjiujitsu.com",
      "https://api.quantifyjiujitsu.com",
      "https://api-staging.quantifyjiujitsu.com"
    ]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD", "PATCH"]
    allow_headers = [
      "Content-Type", "content-type",
      "Authorization", "authorization",
      "X-Amz-Date", "x-amz-date",
      "X-Api-Key", "x-api-key",
      "X-Amz-Security-Token", "x-amz-security-token",
      "Access-Control-Allow-Headers",
      "Access-Control-Allow-Origin",
      "Accept",
      "Origin",
      "Referer",
      "User-Agent"
    ]
    expose_headers = ["content-length", "Content-Length", "date", "Date"]
    allow_credentials = true
    max_age = 86400
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
resource "aws_apigatewayv2_route" "search_posts" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /search-posts"
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
  route_key = "POST /newpost"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "edit_post" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "PUT /editpost/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "edit_post_head" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "HEAD /editpost/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "options_edit_profile" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "OPTIONS /editprofile/{user_id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "delete_post" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "DELETE /deletepost/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Game Plan Routes
resource "aws_apigatewayv2_route" "search_gameplans" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /search-gameplans"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "new_gameplan" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /new-gameplan"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "view_gameplan" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /view-gameplan/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "list_gameplans" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /list-gameplans/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "update_gameplans" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /update-gameplans/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "edit_gameplan" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "PUT /edit-gameplan/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "edit_gameplan_head" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "HEAD /edit-gameplan/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Avatar upload route
resource "aws_apigatewayv2_route" "avatar_post" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /avatar"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Avatar OPTIONS route for CORS
resource "aws_apigatewayv2_route" "options_avatar" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "OPTIONS /avatar"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "NONE"
}

# YouTube routes
resource "aws_apigatewayv2_route" "youtube_auth" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /youtube/auth"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "youtube_token_check" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /youtube/token-check"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "youtube_upload_init" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /youtube/upload/init"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "youtube_auth_callback" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /auth/youtube/callback"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# YouTube OPTIONS routes for CORS
resource "aws_apigatewayv2_route" "options_youtube_auth" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "OPTIONS /youtube/auth"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "options_youtube_token_check" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "OPTIONS /youtube/token-check"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "options_youtube_upload_init" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "OPTIONS /youtube/upload/init"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "options_youtube_callback" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "OPTIONS /auth/youtube/callback"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "NONE"
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
    aws_apigatewayv2_route.search_posts,
    aws_apigatewayv2_route.proxy_image,
    aws_apigatewayv2_route.view_post,
    aws_apigatewayv2_route.view_profile,
    aws_apigatewayv2_route.edit_profile,
    aws_apigatewayv2_route.new_post,
    aws_apigatewayv2_route.edit_post,
    aws_apigatewayv2_route.delete_post,
    aws_apigatewayv2_route.avatar_post,
    aws_apigatewayv2_route.options_avatar,
    # YouTube routes
    aws_apigatewayv2_route.youtube_auth,
    aws_apigatewayv2_route.youtube_token_check,
    aws_apigatewayv2_route.youtube_upload_init,
    aws_apigatewayv2_route.youtube_auth_callback,
    aws_apigatewayv2_route.options_youtube_auth,
    aws_apigatewayv2_route.options_youtube_token_check,
    aws_apigatewayv2_route.options_youtube_upload_init,
    aws_apigatewayv2_route.options_youtube_callback,
    # Game plan routes
    aws_apigatewayv2_route.search_gameplans,
    aws_apigatewayv2_route.new_gameplan,
    aws_apigatewayv2_route.view_gameplan,
    aws_apigatewayv2_route.list_gameplans,
    aws_apigatewayv2_route.update_gameplans,
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
    aws_apigatewayv2_route.search_posts,
    aws_apigatewayv2_route.proxy_image,
    aws_apigatewayv2_route.view_post,
    aws_apigatewayv2_route.view_profile,
    aws_apigatewayv2_route.edit_profile,
    aws_apigatewayv2_route.new_post,
    aws_apigatewayv2_route.edit_post,
    aws_apigatewayv2_route.delete_post,
    aws_apigatewayv2_route.avatar_post,
    aws_apigatewayv2_route.options_avatar,
    # YouTube routes
    aws_apigatewayv2_route.youtube_auth,
    aws_apigatewayv2_route.youtube_token_check,
    aws_apigatewayv2_route.youtube_upload_init,
    aws_apigatewayv2_route.youtube_auth_callback,
    aws_apigatewayv2_route.options_youtube_auth,
    aws_apigatewayv2_route.options_youtube_token_check,
    aws_apigatewayv2_route.options_youtube_upload_init,
    aws_apigatewayv2_route.options_youtube_callback,
    # Game plan routes
    aws_apigatewayv2_route.search_gameplans,
    aws_apigatewayv2_route.new_gameplan,
    aws_apigatewayv2_route.view_gameplan,
    aws_apigatewayv2_route.list_gameplans,
    aws_apigatewayv2_route.update_gameplans,

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
    aws_apigatewayv2_route.search_posts,
    aws_apigatewayv2_route.proxy_image,
    aws_apigatewayv2_route.view_post,
    aws_apigatewayv2_route.view_profile,
    aws_apigatewayv2_route.edit_profile,
    aws_apigatewayv2_route.new_post,
    aws_apigatewayv2_route.edit_post,
    aws_apigatewayv2_route.delete_post,
    aws_apigatewayv2_route.avatar_post,
    aws_apigatewayv2_route.options_avatar,
    # YouTube routes
    aws_apigatewayv2_route.youtube_auth,
    aws_apigatewayv2_route.youtube_token_check,
    aws_apigatewayv2_route.youtube_upload_init,
    aws_apigatewayv2_route.youtube_auth_callback,
    aws_apigatewayv2_route.options_youtube_auth,
    aws_apigatewayv2_route.options_youtube_token_check,
    aws_apigatewayv2_route.options_youtube_upload_init,
    aws_apigatewayv2_route.options_youtube_callback,
    # Game plan routes
    aws_apigatewayv2_route.search_gameplans,
    aws_apigatewayv2_route.new_gameplan,
    aws_apigatewayv2_route.view_gameplan,
    aws_apigatewayv2_route.list_gameplans,
    aws_apigatewayv2_route.update_gameplans,
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
