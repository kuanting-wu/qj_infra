# S3 bucket for hosting a Vue.js website
resource "aws_s3_bucket" "vue_website" {
  bucket = "quantifyjiujitsu.com" # Must be globally unique

  tags = {
    Name = "Quantify Jiujitsu Website Bucket"
  }
}

# S3 bucket for storing markdown notes for posts
resource "aws_s3_bucket" "markdown_notes" {
  bucket = "qj-markdown-notes" # Must be globally unique

  tags = {
    Name = "Quantify Jiujitsu Markdown Notes Bucket"
  }
}

# S3 bucket for www subdomain redirect
resource "aws_s3_bucket" "www_redirect" {
  bucket = "www.quantifyjiujitsu.com" # Bucket for www subdomain

  tags = {
    Name = "WWW Redirect Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.vue_website.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Configure public access for the www redirect bucket
resource "aws_s3_bucket_public_access_block" "www_public_access" {
  bucket                  = aws_s3_bucket.www_redirect.id
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

# Bucket policy for www redirect bucket
resource "aws_s3_bucket_policy" "www_policy" {
  bucket = aws_s3_bucket.www_redirect.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.www_redirect.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.www_public_access]
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.vue_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Configure www bucket to redirect to the root domain
resource "aws_s3_bucket_website_configuration" "www_redirect" {
  bucket = aws_s3_bucket.www_redirect.id

  redirect_all_requests_to {
    host_name = "quantifyjiujitsu.com"
    protocol  = "https"
  }
}


# S3 Bucket for Backend Code Storage
resource "aws_s3_bucket" "backend_s3" {
  bucket = "qj-lambda-bucket"
}

# Block Public Access to S3 Bucket
resource "aws_s3_bucket_public_access_block" "backend_s3" {
  bucket = aws_s3_bucket.backend_s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "backend_s3_versioning" {
  bucket = aws_s3_bucket.backend_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "backend_s3_encryption" {
  bucket = aws_s3_bucket.backend_s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Configure access for markdown notes bucket
resource "aws_s3_bucket_public_access_block" "markdown_notes_access" {
  bucket = aws_s3_bucket.markdown_notes.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy for markdown notes bucket to allow public read access
resource "aws_s3_bucket_policy" "markdown_notes_policy" {
  bucket = aws_s3_bucket.markdown_notes.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.markdown_notes.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.markdown_notes_access]
}

# Enable CORS for the markdown notes bucket
resource "aws_s3_bucket_cors_configuration" "markdown_notes_cors" {
  bucket = aws_s3_bucket.markdown_notes.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# S3 bucket for storing user avatar images
resource "aws_s3_bucket" "avatar_bucket" {
  bucket = "qj-user-avatars" # Must be globally unique
  
  tags = {
    Name = "Quantify Jiujitsu User Avatars Bucket"
  }
}

# Block public access for avatar bucket
resource "aws_s3_bucket_public_access_block" "avatar_bucket_access" {
  bucket = aws_s3_bucket.avatar_bucket.id

  # We'll use signed URLs for uploads, but allow public read access
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy for avatar bucket to allow public read access
resource "aws_s3_bucket_policy" "avatar_bucket_policy" {
  bucket = aws_s3_bucket.avatar_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.avatar_bucket.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.avatar_bucket_access]
}

# Enable CORS for the avatar bucket
resource "aws_s3_bucket_cors_configuration" "avatar_bucket_cors" {
  bucket = aws_s3_bucket.avatar_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = [
      "http://localhost:8080",
      "http://localhost:8081",
      "https://quantifyjiujitsu.com", 
      "https://www.quantifyjiujitsu.com",
      "https://dev.quantifyjiujitsu.com",
      "https://staging.quantifyjiujitsu.com"
    ]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Set lifecycle policy to clean up old objects
resource "aws_s3_bucket_lifecycle_configuration" "avatar_bucket_lifecycle" {
  bucket = aws_s3_bucket.avatar_bucket.id

  rule {
    id     = "delete-old-avatars"
    status = "Enabled"
    
    # This filter matches all objects in the bucket
    filter {
      prefix = ""
    }
    
    # Delete objects that are older than 365 days and have been replaced
    # This helps clean up old avatars that are no longer used
    expiration {
      days = 365
    }
  }
}
