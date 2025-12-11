# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  
  tags = {
    Name        = "${var.bucket_name}-bucket"
    env       = var.env
  } 
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
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
  key    = var.s3_object_key     # S3 path
  source = var.s3_object_source
  etag   = filemd5(var.s3_object_etag_source)
}