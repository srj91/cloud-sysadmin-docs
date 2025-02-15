# main.tf

# Configure the AWS provider
provider "aws" {
  region = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

# variables.tf
locals{
  bucket_name = "ppro-s3-${var.customer_name}"
}

# Create an S3 bucket
resource "aws_s3_bucket" "ppro-bucket" {
  bucket = local.bucket_name
}
resource "aws_s3_bucket_acl" "ppro-bucket-acl"{
  bucket = aws_s3_bucket.ppro-bucket.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.ppro-bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}
  

# Add any additional bucket properties or configurations here


# Add any other necessary resource blocks or configurations for the S3 bucket deployment