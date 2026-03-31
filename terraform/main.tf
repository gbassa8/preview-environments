provider "aws" {
  region = "us-east-1"
}

variable "key_name" {
  type = string
}

variable "allowed_ssh_cidr" {
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

resource "aws_security_group" "k3s_sg" {
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

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
  instance_type = "t3.small"
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    curl -sfL https://get.k3s.io | sh -
  EOF

  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  tags = {
    Name = "master_node"
  }
}

output "public_ip" {
  value = aws_instance.k3s_master.public_ip
}
