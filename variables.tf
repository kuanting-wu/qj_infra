data "aws_caller_identity" "current" {}

variable "github_repo" {
  description = "GitHub repository (owner/repo-name)"
  default     = "kuanting-wu/quantifyjiujitsu"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for the Vue.js site"
  default     = "quantifyjiujitsu.com"
}
