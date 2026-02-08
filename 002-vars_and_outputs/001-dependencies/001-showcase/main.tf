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

resource "aws_vpc" "dep_vpc_1" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "dep_vpc_1"
  }
}

resource "aws_subnet" "dep_subnet_1" {
  vpc_id     = aws_vpc.dep_vpc_1.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "dep_subnet_1"
  }
}

resource "aws_instance" "dep_ec2_1" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.dep_subnet_1.id
  
  tags = {
    Name = "dep_ec2_1"
  }
}

resource "aws_vpc" "dep_vpc_2" {
  cidr_block = "10.50.0.0/16"
  
  depends_on = [
    aws_instance.dep_ec2_1
    ]
  
  tags = {
    Name = "dep_vpc_2"
  }
}