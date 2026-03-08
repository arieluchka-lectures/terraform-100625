variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  type        = string
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for the subnet"
  default     = "us-east-1a"
}

variable "tag_name_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "sivan"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "root_volume_size" {
  type        = number
  description = "Root EBS volume size in GB"
  default     = 20
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR allowed to SSH to the instance"
  default     = "0.0.0.0/0"
}