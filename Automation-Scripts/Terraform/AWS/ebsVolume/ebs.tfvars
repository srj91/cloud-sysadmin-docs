# Provide values
aws_region        = "us-west-2"
availability_zone = "us-west-2a"
volume_size       = "20"
instance_id       = "i-052cf0e036eb9c759"
device_name       = "/dev/sdj" # check in the machine whats the last naming of device
type              = "gp3"
#iops              = "3000"
throughput = "125"
tags = {
  Name       = "ppro-learning" #servername
  Type       = "Data-Disk"
  Mountpoint = "/images"
}