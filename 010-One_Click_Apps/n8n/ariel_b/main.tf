terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_region" "current" {}

resource "aws_vpc" "n8n-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "n8n_vpc"
    Practice = "n8n_terraform_practice"
  }
}

resource "aws_subnet" "n8n-subnet" {
  vpc_id                  = aws_vpc.n8n-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "n8n-subnet"
    Practice = "n8n_terraform_practice"
  }
}

resource "aws_route_table" "n8n-route-table" {
  vpc_id = aws_vpc.n8n-vpc.id

  tags = {
    Name = "n8n-route-table"
    Practice = "n8n_terraform_practice"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.n8n_igw.id
  }
}

resource "aws_route_table_association" "assaciation" {
  subnet_id = aws_subnet.n8n-subnet.id
  route_table_id = aws_route_table.n8n-route-table.id
}

resource "aws_internet_gateway" "n8n_igw" {
  vpc_id = aws_vpc.n8n-vpc.id

  tags = {
    Name = "n8n-igw"
    Practice = "n8n_terraform_practice"
  }
}

resource "aws_eip" "n8n-eip" {
  instance = aws_instance.n8n-server.id
  domain = "vpc"

  tags = {
    Name = "n8n-eip"
    Practice = "n8n_terraform_practice"
  }
}

resource "aws_eip_association" "n8n-eip-assaciation" {
  instance_id = aws_instance.n8n-server.id
  allocation_id = aws_eip.n8n-eip.id
}



resource "aws_network_acl" "n8n-nacl" {
  vpc_id     = aws_vpc.n8n-vpc.id
  subnet_ids = [aws_subnet.n8n-subnet.id]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 5678
    to_port    = 5678
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "79.177.133.111/32"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "79.177.133.111/32"
    from_port  = 22
    to_port    = 22
  }

 egress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

 egress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

 egress {
    protocol   = "tcp"
    rule_no    = 150
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "n8n-nacl"
    Practice = "n8n_terraform_practice"
  }
}

resource "aws_security_group" "n8n-sg" {
  name        = "n8n-sg"
  description = "Security group for n8n server"
  vpc_id      = aws_vpc.n8n-vpc.id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "n8n-sg"
    Practice = "n8n_terraform_practice"
  }
}

resource "aws_security_group_rule" "allow-ssh" {
  security_group_id = aws_security_group.n8n-sg.id
  cidr_blocks = ["79.177.133.111/32"]
  type = "ingress"
  to_port = 22
  from_port = 22
  protocol = "tcp"
}

resource "aws_security_group_rule" "allow-n8n-port" {
  security_group_id = aws_security_group.n8n-sg.id
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
  to_port = 5678
  from_port = 5678
  protocol = "tcp"
}

resource "aws_security_group_rule" "allow-icmp" {
  security_group_id = aws_security_group.n8n-sg.id
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
  to_port = -1
  from_port = -1
  protocol = "icmp"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "private_key" {
  content = tls_private_key.ssh_key.private_key_pem
  filename = "C:/Users/abm25/.ssh/n8n_key.pem"
  file_permission = "0400"
}


resource "aws_key_pair" "private_key_for_instance" {
  key_name = "n8n-key"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = {
    Name = "n8n-key"
    Practice = "n8n_terraform_practice"
  }
}

resource "aws_instance" "n8n-server" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.n8n-subnet.id
  
  vpc_security_group_ids = [aws_security_group.n8n-sg.id]
  
  key_name = aws_key_pair.private_key_for_instance.key_name

  user_data = file("./start_script.sh")
  
  tags = {
    Name = "n8n-server"
    Practice = "n8n_terraform_practice"
  }
}
