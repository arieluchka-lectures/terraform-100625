#!/bin/bash
set -euxo pipefail

exec > /var/log/user-data.log 2>&1

echo "===== NEXTCLOUD BOOTSTRAP START ====="

dnf update -y
dnf install -y docker

systemctl enable docker
systemctl start docker

sleep 10

mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

docker --version
docker compose version

systemctl enable amazon-ssm-agent || true
systemctl restart amazon-ssm-agent || true

usermod -aG docker ec2-user || true

mkdir -p /opt/nextcloud
cd /opt/nextcloud

cat > /opt/nextcloud/compose.yaml <<'EOF'
services:
  db:
    image: mariadb:11
    container_name: nextcloud-db
    restart: unless-stopped
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    environment:
      MYSQL_ROOT_PASSWORD: nextcloud_root_password
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_PASSWORD: nextcloud_password
    volumes:
      - db_data:/var/lib/mysql

  app:
    image: nextcloud:apache
    container_name: nextcloud-app
    restart: unless-stopped
    depends_on:
      - db
    ports:
      - "80:80"
    environment:
      MYSQL_HOST: db
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_PASSWORD: nextcloud_password
    volumes:
      - nextcloud_html:/var/www/html
      - nextcloud_data:/var/www/html/data

volumes:
  db_data:
  nextcloud_html:
  nextcloud_data:
EOF

docker compose -f /opt/nextcloud/compose.yaml up -d

echo "===== NEXTCLOUD BOOTSTRAP END ====="