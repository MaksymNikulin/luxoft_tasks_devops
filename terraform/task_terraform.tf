terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_key_pair" "my_key" {
  key_name   = "my_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "httpserver" {
  name        = "httpserver"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # To allow all outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "httpserver"
  }
}

resource "aws_instance" "t2micro_1" {
  instance_type   = "t2.micro"
  ami             = data.aws_ami.amazon_linux.id
  key_name        = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.httpserver.name]
  tags = {
    Name = "t2micro_1"
  }
}

resource "aws_instance" "t2micro_2" {
  instance_type   = "t2.micro"
  ami             = data.aws_ami.amazon_linux.id
  key_name        = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.httpserver.name]
  tags = {
    Name = "t2micro_2"
  }
}
