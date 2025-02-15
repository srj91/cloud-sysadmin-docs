variable "instance_id1" {
  description = "The ID of the first existing instance"
  type        = string
}

#variable "instance_id2" {
#  description = "The ID of the second existing instance"
 # type        = string
#}

variable "aws_region" {
  description = "current region"
  type        = string
  default     = "us-east-1"
}

variable "customer_name" {
  description = "The name of the customer"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  default     = ""
}

variable "ssh_source_cidr" {
  description = "CIDR blocks for SSH access"
  type        = list(string)
}
