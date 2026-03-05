# ============================================
# Part 7: Dns
# ============================================
resource "aws_route53_zone" "public_zone" {
  name = "wizardnet.100625.lol"
  # zone_id = "Z091686525OM56S61OWF3" #the id for the zone wizardnet.100625.lol
  tags = {
    Name = "public-zone"
    date = var.daily_date_tag
  }
}

resource "aws_route53_zone_association" "public_zone_association" {
  zone_id = aws_route53_zone.public_zone.zone_id
  vpc_id  = aws_vpc.main.id
}

resource "aws_route53_record" "load_balancer_record" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = "teamspeak.wizardnet.100625.lol"
  type    = "A"
  ttl     = 300
  records = [aws_lb.loadbalancer.dns_name]
}

resource "aws_route53_record" "app_server_record" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = "appserver.wizardnet.100625.lol"
  type    = "A"
  ttl     = 300
  records = [aws_instance.app_server.private_ip]
}