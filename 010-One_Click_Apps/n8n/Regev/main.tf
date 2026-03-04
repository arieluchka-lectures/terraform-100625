terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
    tls = { source = "hashicorp/tls", version = "~> 4.0" }
    local = { source = "hashicorp/local", version = "~> 2.0" }
    http = { source = "hashicorp/http", version = "~> 3.0" }
  }
}

provider "aws" { region = "us-east-1" }

data "http" "my_ip" {
  url = "https://v4.ident.me/"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "default" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_security_group" "n8n_sg" {
  name = "n8n-sg-restricted"
  vpc_id = aws_vpc.main.id


  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  ingress {
    from_port = 5678
    to_port = 5678
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = pathexpand("~/.ssh/n8n_key.pem")
}

resource "aws_key_pair" "deployer" {
  key_name   = "n8n-deployer-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_instance" "n8n_server" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.n8n_sg.id]

  root_block_device {
    volume_size = 20 
  }

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user
    
    docker volume create n8n_data
    docker run -d \
      --name n8n \
      --restart unless-stopped \
      -p 5678:5678 \
      -e GENERIC_TIMEZONE="Asia/Jerusalem" \
      -e TZ="Asia/Jerusalem" \
      -e N8N_SECURE_COOKIE=false \
      -v n8n_data:/home/node/.n8n \
      docker.n8n.io/n8nio/n8n
  EOF
}

resource "aws_eip" "n8n_eip" {
  domain   = "vpc"
  instance = aws_instance.n8n_server.id
}


resource "aws_route53_record" "n8n_dns" {
  zone_id = "Z084380120DG5V3J3LYJD"
  name    = "regev.100625.lol"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.n8n_eip.public_ip]
}


output "detected_ip" {
  value = chomp(data.http.my_ip.response_body)
}

output "n8n_url" {
  value = "http://regev.100625.lol:5678"
}

output "ssh_command" {
  value = "ssh -i ${local_file.private_key.filename} ec2-user@${aws_eip.n8n_eip.public_ip}"
}