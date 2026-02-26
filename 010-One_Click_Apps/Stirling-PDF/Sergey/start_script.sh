#!/bin/bash

sudo yum update -y 

# Install docker
sudo yum install docker -y

sudo systemctl start docker

sudo systemctl enable docker

# Install docker compose plugin 
sudo yum install docker-compose-plugin -y

# Create app directory
mkdir -p /home/ec2-user/sergey-app

cd /home/ec2-user/sergey-app

#install git
sudo yum install git -y

git clone https://github.com/arieluchka-lectures/terraform-100625/

cd terraform-100625

# Switch branch
git switch Sergey

# Navigate to the docker compose file location
cd 010-One_Click_Apps/Stirling-PDF/Sergey

sudo docker compose up -d