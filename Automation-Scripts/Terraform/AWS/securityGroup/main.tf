
provider "aws" {
  region = var.aws_region
}

data "aws_instance" "existing_instance1" {
  instance_id = var.instance_id1
}

#data "aws_instance" "existing_instance2" {
#  instance_id = var.instance_id2
#}

#data "aws_instance" "existing_instance3" {
#  instance_id = var.instance_id3
#}

resource "aws_security_group" "customized_sg" {
  name        = "${var.customer_name}-SG"
  description = "Security group for ${var.customer_name}"
  vpc_id      = var.vpc_id != "" ? var.vpc_id : null

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.customer_name}-master-SG"
  }

  # ##################### TO BE MODIFIED BLOCKS ###############################


 ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["18.209.3.243/32","35.165.151.4/32","50.227.254.84/30","34.233.213.33/32"]
  description = "${var.customer_name}-server"
}

   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_source_cidr
    description = "Customer IP"
  }


  # ingress {
  #   from_port   = 9584
  #   to_port     = 9595
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "DBCFS"
  # }

  # ingress {
  #   from_port   = 15001
  #   to_port     = 15002
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "Liveconnect"
  # }

  # ingress {
  #   from_port   = 5000
  #   to_port     = 5009
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "staylinked"
  # }

  # ingress {
  #   from_port   = 3006
  #   to_port     = 3006
  #   protocol    = "udp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "staylinked"
  # }

  # ingress {
  #   from_port   = 5000
  #   to_port     = 6000
  #   protocol    = "udp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "staylinked"
  # }

  # ingress {
  #   from_port   = 12000
  #   to_port     = 12100
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "some app ports"
  # }

  # ##################### END OF TO BE MODIFIED BLOCKS ########################

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "http"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "https"
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "49.204.74.210/32",
      "62.216.247.188/32",
      "222.190.127.83/32",
      "67.220.116.110/32",
      "203.145.189.186/32",
    ]
    description = "Aptean VPN"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["3.216.101.33/32"]
    description = "Hera PPro"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["34.233.213.33/32"]
    description = "Athena PPro"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["52.4.233.171/32"]
    description = "Hera2 PPro"
  }
  


  ingress {
    from_port   = 10050
    to_port     = 10051
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Zabbix PROD"
  }

  ingress {
    from_port   = 8834
    to_port     = 8834
    protocol    = "tcp"
    cidr_blocks = ["10.176.0.14/32", "54.156.160.181/32"]
    description = "NessusScanner"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "icmp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all outbound traffic"
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment1" {
  security_group_id    = aws_security_group.customized_sg.id
  network_interface_id = data.aws_instance.existing_instance1.network_interface_id
}

# resource "aws_network_interface_sg_attachment" "sg_attachment2" {
#   security_group_id    = aws_security_group.customized_sg.id
#   network_interface_id = data.aws_instance.existing_instance2.network_interface_id
# }

# resource "aws_network_interface_sg_attachment" "sg_attachment3" {
#   security_group_id    = aws_security_group.customized_sg.id
#   network_interface_id = data.aws_instance.existing_instance3.network_interface_id
# }
