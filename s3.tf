# S3 bucket for hosting a Vue.js website
resource "aws_s3_bucket" "vue_website" {
  bucket = "quantifyjiujitsu.com" # Must be globally unique

  tags = {
    Name = "Quantify Jiujitsu Website Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.vue_website.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# Bucket policy to allow public access to all objects within the bucket
resource "aws_s3_bucket_policy" "vue_policy" {
  bucket = aws_s3_bucket.vue_website.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.vue_website.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.public_access_block]
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.vue_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": ""
    }
}]
EOF
}
