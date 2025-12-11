provider "aws" {
  region = "ap-south-1"
}


resource "aws_s3_bucket" "my_bucket" {
  bucket = "amazon-s3-bucket-backend-tfstate"
  
  tags = {
    Name        = "MyBucket"
    Environment = "Dev"
  }

}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}