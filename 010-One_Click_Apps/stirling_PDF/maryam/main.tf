


## VPC
resource "aws_vpc" "stirling_pdf_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "stirling-pdf-vpc"
  }
}

resource "aws_internet_gateway" "stirling_pdf_igw" {
  vpc_id = aws_vpc.stirling_pdf_vpc.id
  
  tags = {
    Name = "stirling-pdf-igw"
  }
}

# ============================================
#  Subnet
# ============================================

resource "aws_subnet" "stirling_pdf_subnet" {
  vpc_id                  = aws_vpc.stirling_pdf_vpc.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  
  tags = {
    Name = "stirling-pdf-public-subnet"
  }
}




# ============================================
# Route Table
# ============================================

resource "aws_route_table" "stirling_pdf_rt" {
  vpc_id = aws_vpc.stirling_pdf_vpc.id
  
  tags = {
    Name = "stirling-pdf-rt"
  }
}

resource "aws_route" "stirling_pdf_route" {
  route_table_id         = aws_route_table.stirling_pdf_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.stirling_pdf_igw.id
}


# ============================================
#  Route Table Associations
# ============================================

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.stirling_pdf_subnet.id
  route_table_id = aws_route_table.stirling_pdf_rt.id
}


# ============================================
# Part 6: Security Groups
# ============================================


resource "aws_security_group" "app_server" {
  name        = "app-server-sg"
  description = "Security group for application server"
  vpc_id      = aws_vpc.stirling_pdf_vpc.id
  
  ingress {
  description = "SSH access (limit to your IP in production)"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

ingress {
  description = "Stirling-PDF web UI (TCP 8080)"
  from_port   = 8080
  to_port     = 8080
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
    Name = "app-server-sg"
  }
}

# ============================================
# EC2 Instances
# ============================================



resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/private_key_to_exercise.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "app_key_pair" {
  key_name = "ssh_key_for_stirling_pdf"
  public_key = tls_private_key.ssh_key.public_key_openssh
}





resource "aws_instance" "stirling_pdf_app" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t3.small"
  subnet_id     = aws_subnet.stirling_pdf_subnet.id  
  
  vpc_security_group_ids = [aws_security_group.app_server.id]  

  key_name               = aws_key_pair.app_key_pair.key_name

  tags = {
    Name = "stirling-pdf-app"
  }
}

