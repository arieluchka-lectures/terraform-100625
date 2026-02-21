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

# -------------------------
# Networking: VPC + Subnet
# -------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "nextcloud-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "nextcloud-public-subnet"
  }
}

# -------------------------
# Internet Gateway + Routes
# -------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "nextcloud-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # 0.0.0.0/0 -> IGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "nextcloud-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# -------------------------
# Elastic IP
# -------------------------
resource "aws_eip" "public_ip" {
  domain = "vpc"

  tags = {
    Name = "nextcloud-eip"
  }
}

# -------------------------
# NACL (stateless) for service ports (80/443)
# Must allow return traffic on ephemeral ports
# -------------------------
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public.id]

  # Inbound: allow HTTP/HTTPS from anywhere
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Inbound: allow ephemeral ports for return traffic
  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Outbound: allow HTTP/HTTPS out
  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Outbound: allow ephemeral ports (common for responses)
  egress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "nextcloud-public-nacl"
  }
}

# -------------------------
# Security Group for service ports (stateful)
# -------------------------
resource "aws_security_group" "service_sg" {
  name        = "nextcloud-service-sg"
  description = "Allow web traffic to Nextcloud"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Stateful SG: outbound typically allow all
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nextcloud-service-sg"
  }
}

# -------------------------
# Outputs
# -------------------------
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "eip_allocation_id" {
  value = aws_eip.public_ip.id
}

output "service_sg_id" {
  value = aws_security_group.service_sg.id
}

# -------------------------
# AMI: Amazon Linux 2023
# -------------------------
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# -------------------------
# IAM: SSM role/profile for EC2
# -------------------------
resource "aws_iam_role" "ec2_ssm_role" {
  name = "nextcloud-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "nextcloud-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# -------------------------
# EC2: Nextcloud host
# -------------------------
resource "aws_instance" "nextcloud" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.small" 
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.service_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "nextcloud-ec2"
  }
}

# -------------------------
# Attach the Elastic IP to EC2
# -------------------------
resource "aws_eip_association" "nextcloud_eip" {
  allocation_id = aws_eip.public_ip.id
  instance_id   = aws_instance.nextcloud.id
}

output "instance_id" {
  value = aws_instance.nextcloud.id
}

output "elastic_ip" {
  value = aws_eip.public_ip.public_ip
}
