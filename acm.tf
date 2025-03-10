resource "aws_acm_certificate" "api_cert" {
  domain_name       = "api.quantifyjiujitsu.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "api_dev_cert" {
  domain_name       = "api-dev.quantifyjiujitsu.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "api_staging_cert" {
  domain_name       = "api-staging.quantifyjiujitsu.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
