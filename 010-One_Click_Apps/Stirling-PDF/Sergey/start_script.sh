#!/bin/bash

#update system packages
sudo yum update -y 

# Install docker
sudo yum install docker -y

sudo systemctl start docker

sudo systemctl enable docker

# Create app directory
sudo mkdir -p /usr/libexec/docker/cli-plugins

sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/libexec/docker/cli-plugins/docker-compose

sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose

# Create app directory
mkdir -p /home/ec2-user/sergey-app

cd /home/ec2-user/sergey-app

#install git
sudo yum install git -y

sudo git clone https://github.com/arieluchka-lectures/terraform-100625/

cd terraform-100625

# Switch branch
sudo git switch Sergey

# Navigate to the docker compose file location
cd 010-One_Click_Apps/Stirling-PDF/Sergey

# run docker compose
sudo docker compose up -d