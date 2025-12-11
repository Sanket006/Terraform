provider "aws" {
  region = "ap-south-1"
}

# Launch Template for Auto Scaling Group
resource "aws_launch_template" "foobar" {
  name_prefix   = "foobar"
  image_id      = "ami-02b8269d5e85954ef"
  instance_type = "t3.micro"
}

# Auto Scaling Group
resource "aws_autoscaling_group" "bar" {
  availability_zones = ["ap-south-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.foobar.id
    version = "$Latest"
  }
}

###---------------------------------------------

# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name-123456"
  
  tags = {
    Name        = "MyBucket"
    env       = "dev"
  } 
}

# Upload a file to the S3 bucket
resource "aws_s3_object" "website_file" {
  bucket = aws_s3_bucket.my_bucket.bucket
  key    = "my-website/index.html"     # S3 path
  source = "/root/index.html"
  etag   = filemd5("/root/index.html")
}

###---------------------------------------------

