terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


# ============================================
# Part 1: VPC
# ============================================

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = XXX
  
  tags = {
    Name = "main-igw"
  }
}

# ============================================
# Part 2: Subnets
# ============================================

resource "aws_subnet" "public" {
  vpc_id                  = XXX
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = XXX
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
  allocation_id = XXX
  subnet_id     = XXX
  
  tags = {
    Name = "main-nat-gateway"
  }
}

# ============================================
# Part 4: Route Tables
# ============================================

resource "aws_route_table" "public" {
  vpc_id = XXX
  
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = XXX
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = XXX
}

resource "aws_route_table" "private" {
  vpc_id = XXX
  
  tags = {
    Name = "private-rt"
  }
}

resource "aws_route" "private_nat_access" {
  route_table_id         = XXX
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = XXX
}

# ============================================
# Part 5: Route Table Associations
# ============================================

resource "aws_route_table_association" "public" {
  subnet_id      = XXX
  route_table_id = XXX
}

resource "aws_route_table_association" "private" {
  subnet_id      = XXX
  route_table_id = XXX
}

# ============================================
# Part 6: Security Groups
# ============================================

resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = XXX
  
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
  vpc_id      = XXX
  
  ingress {
    description     = "SSH from bastion only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [XXX]
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

resource "aws_instance" "bastion" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t3.micro"
  subnet_id     = XXX
  
  vpc_security_group_ids = [XXX]
  
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
  subnet_id     = XXX  
  
  vpc_security_group_ids = [XXX]  
  
  tags = {
    Name = "app-server"
  }
}