# variable definitions

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "availability_zone" {
  description = "provide the availablity sone for volume to get creaed in"
  type        = string
}

variable "volume_size" {
  description = "provide Volume size in GB"
  type        = number
}

variable "tags" {
  description = "Provide tags for the volume"
  type        = map(string)
}

variable "device_name" {
  description = "specify device name"
  type        = string
}

variable "instance_id" {
  description = "provide EC2 instance ID"
  type        = string
}

variable "type" {
  description = "Provide type of volume (gp2, io1, st1, sc1)"
  type        = string
}

variable "iops" {
  description = "Provide IOPS for io1 type volume"
  type        = number
  default     = 3000
}

variable "throughput" {
  description = "Provide throughput for the volume"
  type        = number
}