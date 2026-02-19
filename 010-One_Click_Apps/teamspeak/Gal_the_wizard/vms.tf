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

  depends_on = [aws_nat_gateway.main, aws_route_table.private, aws_instance.bastion]
  user_data  = local.start_sh

  tags = {
    Name = "app-server"
  }
}