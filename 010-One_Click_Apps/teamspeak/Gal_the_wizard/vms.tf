# ============================================
# Part 7: EC2 Instances
# ============================================

resource "aws_instance" "bastion" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = aws_key_pair.bastion_key.key_name


  tags = {
    Name = "bastion-host"
  }
}


# This instance should not launch until:
# 1. NAT Gateway is ready
# 2. Private route table association is complete
# 3. Bastion host is created
resource "aws_instance" "app_server" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private.id

  vpc_security_group_ids = [aws_security_group.app_server.id]
  key_name               = aws_key_pair.bastion_key.key_name

  depends_on = [ aws_nat_gateway.main, aws_route_table.private, aws_instance.bastion ]
  user_data = <<-EOF
              #!/bin/bash

              cat << 'EOT' > /home/ec2-user/docker-compose.yml
              services:
                  teamspeak:
                    image: teamspeak
                    restart: always
                    ports:
                      - 9987:9987/udp
                      - 10011:10011
                      - 30033:30033
                    environment:
                      TS3SERVER_DB_PLUGIN: ts3db_mariadb
                      TS3SERVER_DB_SQLCREATEPATH: create_mariadb
                      TS3SERVER_DB_HOST: db
                      TS3SERVER_DB_USER: root
                      TS3SERVER_DB_PASSWORD: example
                      TS3SERVER_DB_NAME: hogwarts
                      TS3SERVER_DB_WAITUNTILREADY: 30
                      TS3SERVER_LICENSE: accept
                  db:
                    image: mariadb
                    restart: always
                    environment:
                      MYSQL_ROOT_PASSWORD: example
                      MYSQL_DATABASE: teamspeak





              EOT

              dnf update -y
              dnf install -y docker
              sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              docker-compose version >> /home/ec2-user/log.txt
              sudo systemctl enable docker
              sudo systemctl start docker

              cd /home/ec2-user/
              docker compose up -d
              

              
              EOF
 
  tags = {
    Name = "app-server"
  }
}