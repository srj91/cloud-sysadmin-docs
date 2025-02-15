variable "aws_region" {
  description = "The AWS region where the S3 bucket will be created"
  type        = string
  default     = "ap-south-1"
}

variable "customer_name"{
  description = "Name Of the customer for the S3 Bucket"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "access_key" {
  description = "The AWS access key"
  type        = string
  default     = "AKIA6RTMVHBVB4D2XBOP"
}

variable "secret_key" {
  description = "The AWS secret key"
  type        = string
  default     = "aCXtPL+au4d9jg+l1KQ5ZkI9h987BoEdzV+qqUsU"  
}

