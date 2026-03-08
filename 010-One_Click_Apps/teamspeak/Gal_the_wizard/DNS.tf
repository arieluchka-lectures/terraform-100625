# ============================================
# Part 7: Dns
# ============================================

#=============================================
# Zones & associations
#=============================================
resource "aws_route53_zone" "public_zone" {
  name = "wizardnet.100625.lol"
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = "public-zone"
    date = var.daily_date_tag
  }
}

# resource "aws_route53_zone_association" "public_zone_association" {  this is for private hosted zones saved for private dns resolution within the vpc 
#   zone_id = aws_route53_zone.public_zone.zone_id
#   vpc_id  = aws_vpc.main.id
# }r




#=============================================  
# Records
#============================================
resource "aws_route53_record" "load_balancer_record" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = "teamspeak.wizardnet.100625.lol"
  type    = "A"
  ttl     = 300
  records = [aws_eip.lb.public_ip]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = "www.wizardnet.100625.lol"
  type    = "CNAME"
  ttl     = 300
  records = ["wizardnet.100625.lol"]
}

resource "aws_route53_record" "app_server_record" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = "appserver.wizardnet.100625.lol"
  type    = "A"
  ttl     = 300
  records = [aws_instance.app_server.private_ip]
}