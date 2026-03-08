#!/bin/sh

cat <<'EOT'> /home/ec2-user/docker-compose.yml
services:
  teamspeak:
    container_name: teamspeak
    image: teamspeak
    restart: always
    network_mode: host
    environment:
      TS3SERVER_DB_PLUGIN: ts3db_mariadb
      TS3SERVER_DB_SQLCREATEPATH: create_mariadb
      TS3SERVER_DB_HOST: 127.0.0.1
      TS3SERVER_DB_USER: root
      TS3SERVER_DB_PASSWORD: ${TS3SERVER_DB_PASSWORD}
      TS3SERVER_DB_NAME: ${TS3SERVER_DB_NAME}
      TS3SERVER_DB_WAITUNTILREADY: 30
      TS3SERVER_LICENSE: accept
  db:
    container_name: db
    image: mariadb
    restart: always
    network_mode: host
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
EOT


dnf update -y
dnf install -y docker
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose version >> /home/ec2-user/log.txt
sudo systemctl enable docker
sudo systemctl start docker
cd /home/ec2-user/
sudo docker-compose up -d
              

              
              


