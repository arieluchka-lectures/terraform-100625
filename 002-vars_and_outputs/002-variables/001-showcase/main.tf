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


resource "aws_vpc" "main" {
  cidr_block           = var.cidr_for_vpc
  enable_dns_hostnames = true
  enable_dns_support   = true
  
#   tags = {
#     vars.tags
#   }
}


variable "cidr_for_vpc" {
    type = string
    description = "The network CIDR for the vpc"
}


variable "var1" {
    type = string
    description = "The network CIDR for the vpc"
}


# variable "tags" {
#     type = map
#     # description = "The network CIDR for the vpc"
#     # sensitive = true
# }