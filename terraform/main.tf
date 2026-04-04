provider "aws" {
  region = "us-east-1"
}

variable "key_name" {
  type = string
}

variable "tailscale_auth_key" {
  type      = string
  sensitive = true
}

variable "eip_allocation_id" {
  # crear ip en la consola para evitar perder la ip fija con el destroy
  type = string
}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_eip" "k3s_master" {
  id = var.eip_allocation_id
}

resource "aws_security_group" "k3s_sg" {
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k3s_master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  key_name      = var.key_name

  user_data = templatefile("${path.module}/cloud-init.yaml", {
    tailscale_auth_key = var.tailscale_auth_key
    traefik_public_ip  = data.aws_eip.k3s_master.public_ip
  })

  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  tags = {
    Name = "athenea"
  }
}

resource "aws_eip_association" "k3s_master" {
  instance_id   = aws_instance.k3s_master.id
  allocation_id = var.eip_allocation_id
}
