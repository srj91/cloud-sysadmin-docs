variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "access_key" {
  description = "The access key for API operations"
  type        = string
  default     = "AKIA6RTMVHBVB4D2XBOP"
}

variable "secret_key" {
  description = "The secret key for API operations"
  type        = string
  default     = "aCXtPL+au4d9jg+l1KQ5ZkI9h987BoEdzV+qqUsU"
}

variable "user_name" {
  description = "The name of the IAM user"
  type        = string
}