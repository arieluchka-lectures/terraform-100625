#!/bin/bash
set -euxo pipefail

exec > /var/log/user-data.log 2>&1

echo "===== BOOTSTRAP START ====="

dnf update -y
dnf install -y docker git curl wget unzip

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

mkdir -p /opt/nginx-demo

cat > /opt/nginx-demo/index.html <<'EOF'
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Terraform Service</title>
</head>
<body style="font-family: Arial; text-align: center; margin-top: 60px;">
  <h1>Nginx is running in Docker</h1>
  <p>Provisioned with Terraform + user_data</p>
</body>
</html>
EOF

docker pull nginx:latest

docker run -d \
  --name nginx-demo \
  --restart unless-stopped \
  -p 80:80 \
  -v /opt/nginx-demo/index.html:/usr/share/nginx/html/index.html:ro \
  nginx:latest

echo "===== BOOTSTRAP DONE ====="