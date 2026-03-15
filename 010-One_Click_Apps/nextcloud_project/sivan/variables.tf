variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "tag_name_prefix" {
  type        = string
  description = "Prefix for tags/names"
  default     = "sivan-nextcloud"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  type        = string
  description = "Public subnet CIDR"
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone"
  default     = "us-east-1a"
}

variable "instance_type" {
  type        = string
  description = "EC2 type chosen for Nextcloud"
  default     = "t3.small"
}

variable "root_volume_size" {
  type        = number
  description = "Root disk size in GB"
  default     = 30
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "Who can SSH"
  default     = "0.0.0.0/0"
}

variable "nextcloud_host_port" {
  type        = number
  description = "Host port for Nextcloud"
  default     = 80
}