/*
if the volume on portal getting added as /dev/sdh 
then in machine it will be visible as /dev/xvdh
*/

# Initiate AWS Provider and define resource block
provider "aws" {
  region = var.aws_region
}

# Craete EBS Volume
resource "aws_ebs_volume" "ebs_vol" {
  availability_zone = var.availability_zone
  size              = var.volume_size
  tags              = var.tags
  type              = var.type
  iops              = var.iops
  throughput        = var.throughput
}

# Attach Volume to Instance
resource "aws_volume_attachment" "ebs_attach" {
  device_name = var.device_name
  instance_id = var.instance_id
  volume_id   = aws_ebs_volume.ebs_vol.id
}


