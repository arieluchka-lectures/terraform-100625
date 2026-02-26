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
# Part 3: NAT Gateway Setup
# ============================================

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
# Part 6: ACL's
# ============================================

# resource "aws_network_acl" "main" {
#   vpc_id     = aws_vpc.main.id
#   subnet_ids = [aws_subnet.public.id]

#   ingress { #SSH
#     protocol   = "tcp"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "0.0.0.0/0" 
#     from_port  = 22
#     to_port    = 22
#   }

# ingress {
#     protocol   = "tcp"
#     rule_no    = 110
#     action     = "allow"
#     cidr_block = "0.0.0.0/0" 
#     from_port  = 1024
#     to_port    = 65535
#   }

# ingress { # Stirling-PDF
#     protocol   = "tcp"
#     rule_no    = 200
#     action     = "allow"
#     cidr_block = "0.0.0.0/0" 
#     from_port  = 9080
#     to_port    = 9080
#   }

# ingress { # Stirling-PDF
#     protocol   = "tcp"
#     rule_no    = 300
#     action     = "deny"
#     cidr_block = "0.0.0.0/0" 
#     from_port  = 0
#     to_port    = 0
#   }

# egress {
#     protocol   = "-1"
#     rule_no    = 90
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }

# }


# ============================================
# Part 7: Security Groups
# ============================================



resource "aws_security_group" "ec2_sg" {
  name   = "ec2-public-sg"
  vpc_id = aws_vpc.main.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Stirling-PDF
  ingress {
    from_port   = 9080
    to_port     = 9080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ============================================
# Part 8: EC2 Instances
# ============================================
resource "aws_instance" "app_server" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t3.small"
  subnet_id     = aws_subnet.public.id 
  key_name = aws_key_pair.public_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]  

  tags = {
    Name = "New-S-instance"
  }

  user_data = file("${path.module}/start_script.sh")

}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "C:/Users/User/.ssh/private_key_excercise.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "public_key" {
  key_name = "ssh_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}


output "public_ip" {
  value = aws_instance.app_server.public_ip
  
}

output "vpc_id" {
  value = aws_vpc.main.id
  
}

output "ssh_command" {
 
  value = "ssh -i ${local_file.private_key.filename} ec2-user@${aws_instance.app_server.public_ip}"

}