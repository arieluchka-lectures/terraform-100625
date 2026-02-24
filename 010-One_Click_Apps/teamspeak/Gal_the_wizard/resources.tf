
# ============================================
# part 0: keys
# ============================================
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096

}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = "${path.module}/id_rsa"
  file_permission = "0400"
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "ssh_key_for_bastion"
  public_key = tls_private_key.ssh_key.public_key_openssh
}
# ============================================
# Part 1: VPC
# ============================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
     Name = var.daily_date_tag
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
    Name = var.daily_date_tag
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
    Name = var.daily_date_tag
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet"
     Name = var.daily_date_tag
  }
}

# ============================================
# Part 3: NAT Gateway Setup
# ============================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
     Name = var.daily_date_tag
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "main-nat-gateway"
     Name = var.daily_date_tag
  }
}

# ============================================
# Part 4: Route Tables
# ============================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-rt"
     Name = var.daily_date_tag
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

  tags = {
    Name = "public-internet-access"
     Name = var.daily_date_tag
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt"
     Name = var.daily_date_tag
  }
}

resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id

  tags = {
    Name = "private-nat-access"
     Name = var.daily_date_tag
  }
}

# ============================================
# Part 5: Route Table Associations
# ============================================

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id

  tags = {
    Name = "public-rt-association"
     Name = var.daily_date_tag
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id

  tags = {
    Name = "private-rt-association"
     Name = var.daily_date_tag
  }
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
    Name = var.daily_date_tag
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
    Name = var.daily_date_tag
  }
}

