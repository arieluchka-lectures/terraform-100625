#!/bin/bash
yum update -y
yum install -y docker
service docker start
usermod -aG docker ec2-user
mkdir -p ~/stirling-data
docker run -d \
  --name stirling-pdf \
  -p 8080:8080 \
  -v ~/stirling-data:/configs \
  --restart unless-stopped \
  stirlingtools/stirling-pdf:latest