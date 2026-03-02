#!/bin/bash

sleep 30

sudo yum install docker -y

sleep 10

sudo systemctl start docker
sudo docker volume create n8n_data
sudo docker run -d --name n8n -p 5678:5678 -e N8N_HOST=0.0.0.0 -e N8N_PORT=5678 -e N8N_PROTOCOL=http -e N8N_SECURE_COOKIE=false -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n
