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
    Name = "New-S-main-vpc"
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
  gateway_id             = aws_internet_gateway.main.id # (internet gateway (from part 1))
}



# ============================================
# Part 5: Route Table Associations
# ============================================

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}




# ============================================
# Part 7: Security Groups
# ============================================



resource "aws_security_group" "ec2_sg" {
  name   = "ec2-public-sg"
  vpc_id = aws_vpc.main.id
}


  # Stirling-PDF_port
resource "aws_vpc_security_group_ingress_rule" "allow_port" {
  security_group_id = aws_security_group.ec2_sg.id
  from_port   = 9080
  to_port     = 9080
  ip_protocol = "tcp"
  cidr_ipv4 =  "0.0.0.0/0"
}



  # Outbound 
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.ec2_sg.id
  ip_protocol = "-1"
  cidr_ipv4  = "0.0.0.0/0"
}

# ============================================
# Part 8: EC2 Instances
# ============================================
resource "aws_instance" "app_server" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t3.small"
  subnet_id     = aws_subnet.public.id 
  
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]  

  tags = {
    Name = "New-S-instance"
  }

  user_data = file("${path.module}/start_script.sh")

}

