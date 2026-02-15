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


resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "main-igw"
  }
}

# ============================================
# Part 2: Subnets
# ============================================

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "private-subnet"
  }
}

# ============================================
# Part 3: NAT Gateway Setup
# ============================================

resource "aws_eip" "nat" {
  domain = "vpc"
  
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  
  tags = {
    Name = "main-nat-gateway"
  }
}

# ============================================
# Part 4: Route Tables
# ============================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "private-rt"
  }
}

resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# ============================================
# Part 5: Route Table Associations
# ============================================

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# ============================================
# Part 6: Security Groups
# ============================================

resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_security_group" "app_server" {
  name        = "app-server-sg"
  description = "Security group for application server"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description     = "SSH from bastion only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "app-server-sg"
  }
}

# ============================================
# Part 7: EC2 Instances
# ============================================



resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "C:/Users/sela.sc.ariel.agra/.ssh/private_key_to_exercise.txt"
  file_permission = "0400"
}



resource "aws_key_pair" "public_bastion_key" {
  key_name = "ssh_key_for_bastion"
  public_key = tls_private_key.ssh_key.public_key_openssh
}




resource "aws_instance" "bastion" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  key_name               = aws_key_pair.public_bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  tags = {
    Name = "bastion-host"
  }
}



  # This instance should not launch until:
  # 1. NAT Gateway is ready
  # 2. Private route table association is complete
  # 3. Bastion host is created
resource "aws_instance" "app_server" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private.id  
  
  vpc_security_group_ids = [aws_security_group.app_server.id]  

  key_name               = aws_key_pair.public_bastion_key.key_name

  depends_on = [
    aws_nat_gateway.main,
    aws_route_table_association.private,
    aws_instance.bastion
  ]
  
  tags = {
    Name = "app-server"
  }
}

output "vpc_id" {
 value = aws_vpc.main.id
}
  
output "bastion_public_ip" {
 value = aws_instance.bastion.public_ip
}


output "app_server_private_ip" {
 value = aws_instance.app_server.private_ip
}


output "combined_message" {
  value = <<-BANANA
Connect to the bastion with:
  
  ssh -A -i ${local_file.private_key.filename} ec2-user@${aws_instance.bastion.public_ip}

from bation, connect to app-server with: 

  ssh -A ec2-user@${aws_instance.app_server.private_ip}
  
BANANA
}

