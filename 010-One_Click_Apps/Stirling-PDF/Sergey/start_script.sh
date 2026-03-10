#!/bin/bash

#update system packages
yum update -y 

# Install docker
yum install docker -y

systemctl start docker

systemctl enable docker

# Create app directory
mkdir -p /usr/libexec/docker/cli-plugins

curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/libexec/docker/cli-plugins/docker-compose

chmod +x /usr/libexec/docker/cli-plugins/docker-compose


mkdir -p /home/ec2-user/sergey-app

cd /home/ec2-user/sergey-app

#install git
yum install git -y

git clone https://github.com/arieluchka-lectures/terraform-100625/

cd terraform-100625

# Switch branch
git switch Sergey

# Navigate to the docker compose file location
cd 010-One_Click_Apps/Stirling-PDF/Sergey

cat > .env <<EOF
IMAGE_TAG=${app_image_tag}
HOST_PORT=${app_port}
EOF

# run docker compose
docker compose up -d