data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

variable "frontend_github_repo" {
  description = "GitHub repository (owner/repo-name)"
  default     = "kuanting-wu/qj_frontend"
}

variable "backend_github_repo" {
  description = "GitHub repository (owner/repo-name)"
  default     = "kuanting-wu/qj_lambda"
}

variable "frontend_s3_bucket_name" {
  description = "S3 bucket name for the Vue.js site"
  default     = "quantifyjiujitsu.com"
}

variable "backend_s3_bucket_name" {
  description = "S3 bucket name for the Lambda backend code"
  default     = "qj-lambda-bucket"
}

variable "my_ip" {
  description = "Your IP address for SSH access to bastion (format: x.x.x.x)"
  type        = string
  default = "98.28.240.37"
}

variable "ssh_public_key" {
  description = "SSH public key for bastion access"
  type        = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtDdrFYI/EW2cuvG+9mwoa1Mp/ueI9Hv4n4auK7bSeDBF4H4D5Ah9jzVYr5ev8Gb9z5acNQbeL6xldHzFUvBKrZDYrmcGwTqLtqz0CXXrsxU1/1kbY1Oca+tii2iaUgUAlzFbIQIrM1ZEPgZH3DgwpkH9jeJLIRVJOVNLMtlF6Qa55QusHDTNWcwCIofKIU0fEo7Pr6CT/PnuYd00nD6ROFWP7+91T2seSHbWtxoX9DsdjA5+CdUdiVOOuh8lkp8bxSHRGEGLH0E56QJ0in5tUJEIU8ITRySLMTkow+nzr2u2OWvlljh9XIrFLyeedszTrqVK6e1hlwmomlalfdimp"
}

variable "ses_email_from" {
  description = "Email address to send verification emails from (must be verified in SES)"
  type        = string
  default     = "noreply@quantifyjiujitsu.com"
}
