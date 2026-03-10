terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


# ============================================
# Part 1: VPC
# ============================================

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    
    
    Name = "${var.VAR_NAME}-New-main-vpc"
    
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.VAR_NAME}-main-igw"
  }
}

# ============================================
# Part 2: Subnets
# ============================================

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.VAR_NAME}-public-subnet"
  }
}


# ============================================
# Part 3: Route Tables
# ============================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.VAR_NAME}-public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id # (internet gateway (from part 1))
}



# ============================================
# Part 4: Route Table Associations
# ============================================

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}




# ============================================
# Part 5: Security Groups
# ============================================



resource "aws_security_group" "ec2_sg" {
  name   = "${var.VAR_NAME}-ec2-public-sg"
  vpc_id = aws_vpc.main.id
}


  # Stirling-PDF_port
resource "aws_vpc_security_group_ingress_rule" "allow_port" {
  security_group_id = aws_security_group.ec2_sg.id
  from_port   = var.app_port
  to_port     = var.app_port
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
# Part 6: ACL
# ============================================
resource "aws_network_acl" "new_acl" {
    vpc_id = aws_vpc.main.id

    egress {
        protocol = "tcp"
        rule_no = 200
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = var.app_port
        to_port = var.app_port
    }
    
    egress {
    protocol   = "tcp"
    rule_no    = 210
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
    
    ingress {
        protocol = "tcp"
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = var.app_port
        to_port = var.app_port
    }

    ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

    tags = {
      Name = "${var.VAR_NAME}-ACL"
    
  }
}

resource "aws_network_acl_association" "main_ACL" {
  subnet_id      = aws_subnet.public.id
  network_acl_id = aws_network_acl.new_acl.id
}

# ============================================
# Part 7: EC2 Instances
# ============================================
resource "aws_instance" "app_server" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = var.aws_instance_type
  subnet_id     = aws_subnet.public.id 
  
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]  

  tags = {
    Name = "${var.VAR_NAME}-New-instance"
  }

  user_data = templatefile("${path.module}/start_script.sh", 
  {app_port = var.app_port
   app_image_tag = var.app_image_tag
  })

}
# ============================================
# Part 8: Variables
# ============================================

variable "VAR_NAME" {
  type = string
  description = "name_variable"
  default = "Sergey"
}


variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "app_port" {
  type = number
  default = 9080
}

variable "app_image_tag" {
  type = string
  default = "latest"
}

variable "aws_instance_type" {

  type = string

  description = "The ec2 instance type"

  default = "t3.small"

  validation {

    condition = contains(["t3.small", "c7i-flex.large", "m7i-flex.large"], var.aws_instance_type)

    error_message = "Wrong EC2 type!!!! Instance type must be: t3.small, c7i-flex.large, m7i-flex.large."

  }
}


