
# ============================================
# part 0: keys
# ============================================
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096

}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = "${path.module}/.ssh/id_rsa"
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
    date = var.daily_date_tag
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
    date = var.daily_date_tag
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
    date = var.daily_date_tag
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet"
    date = var.daily_date_tag
  }
}

# ============================================
# Part 3: NAT Gateway Setup
# ============================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
    date = var.daily_date_tag
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "main-nat-gateway"
    date = var.daily_date_tag
  }
}

# ============================================
# Part 4: Route Tables
# ============================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-rt"
    date = var.daily_date_tag
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
    date = var.daily_date_tag
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
  ingress {
    description = "Teamspeak voice traffic"
    from_port   = 9987
    to_port     = 9987
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Teamspeak query traffic"
    from_port   = 10011
    to_port     = 10011
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Teamspeak file transfer traffic"
    from_port   = 30033
    to_port     = 30033
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP for TS3 Webinterface"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["176.228.47.195/32"] # Only allow HTTP from my home IP for security  
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "bastion-sg"
    date = var.daily_date_tag
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

  ingress {
    description     = "Teamspeak voice traffic"
    from_port       = 9987
    to_port         = 9987
    protocol        = "udp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description     = "Teamspeak query traffic"
    from_port       = 10011
    to_port         = 10011
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  ingress {
    description     = "Teamspeak file transfer traffic"
    from_port       = 30033
    to_port         = 30033
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description     = "HTTP for TS3 Webinterface"
    from_port       = 80
    to_port         = 80
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
    date = var.daily_date_tag
  }
}

# ============================================
# Part 7: Dns
# ============================================

resource "aws_route53_zone" "private_zone" {
  name = "private.wizardnet.100625.lol"
  lifecycle {
    ignore_changes = [vpc]

  }
  tags = {
    Name = "private-zone"
    date = var.daily_date_tag
  }

}
resource "aws_route53_zone" "public_zone" {
  name = "wizardnet.100625.lol"
  lifecycle {
    ignore_changes = [vpc]

  }
  tags = {
    Name = "public-zone"
    date = var.daily_date_tag
  }

}
resource "aws_route53_zone_association" "private_zone_association" {
  zone_id = aws_route53_zone.private_zone.zone_id
  vpc_id  = aws_vpc.main.id

}