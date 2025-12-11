variable "bucket_name" {
  default = "my-unique-bucket-name-123456"
}

variable "env" {
  default = "dev"
}

variable "s3_object_key" {
  default = "my-website/index.html"
}

variable "s3_object_source" {
  default = "/root/index.html"
}

variable "s3_object_etag_source" {
  default = "/root/index.html"
}
