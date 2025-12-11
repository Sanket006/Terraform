output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.my_bucket.arn
}

output "s3_object_url" {
  value = aws_s3_object.website_file.id
}
