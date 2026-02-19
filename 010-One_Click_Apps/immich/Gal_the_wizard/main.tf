terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    version = "~> 5.0" }
  }
}


provider "aws" {
  region = "us-east-1"
}

# ============================================
# Networking
# ============================================

#VPC
resource "aws_vpc" "immich" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "immich-vpc"
  }
}

resource "aws_internet_gateway" "immich_igw" {
  vpc_id = aws_vpc.immich.id

  tags = {
    Name = "immich-igw"
  }

}


#Subnets
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.immich.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "immich-public-subnet"
  }
}

resource "aws_subnet" "app_network" {
  vpc_id            = aws_vpc.immich.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "immich-app-subnet"
  }

}

#NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "immich-nat-eip"
  }

}
resource "aws_nat_gateway" "immich_nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "immich-nat-gateway"
  }

}

#Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.immich.id
  tags = {
    Name = "immich-public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0/0"
  gateway_id             = aws_internet_gateway.immich_igw.id
}
resource "aws_route_table" "app_network_rt" {
  vpc_id = aws_vpc.immich.id
  tags = {
    Name = "immich-app-network-rt"
  }

}

resource "aws_route" "app_network_internet_access" {
  route_table_id         = aws_route_table.app_network_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.immich_nat.id

}

# Route Table Associations
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
    