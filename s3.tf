# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name-123456"
  
  tags = {
    Name        = "MyBucket"
    env       = "dev"
  } 
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload a file to the S3 bucket
resource "aws_s3_object" "website_file" {
  bucket = aws_s3_bucket.my_bucket.bucket
  key    = "my-website/index.html"     # S3 path
  source = "C:/Users/Lenovo/Downloads/my-website/index.html"
  etag   = filemd5("C:/Users/Lenovo/Downloads/my-website/index.html")
}

# Upload multiple files to the S3 bucket
locals {
  website_files = fileset("C:/Users/Lenovo/Downloads/my-website", "**")
}

resource "aws_s3_object" "website" {
  for_each = { for file in local.website_files : file => file }

  bucket = aws_s3_bucket.my_bucket.bucket
  key    = each.key
  source = "C:/Users/Lenovo/Downloads/my-website/${each.key}"
  etag   = filemd5("C:/Users/Lenovo/Downloads/my-website/${each.key}")
}
