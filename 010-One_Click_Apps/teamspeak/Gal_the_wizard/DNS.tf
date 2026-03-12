# ============================================
# Part 7: Dns
# ============================================

#=============================================
# Zones & associations
#=============================================
data "aws_route53_zone" "public_zone" {
  zone_id = "Z0074030LL1W8YOCAXF2"
}



#=============================================  
# Records
#============================================
resource "aws_route53_record" "load_balancer_record" {
  zone_id = data.aws_route53_zone.public_zone.zone_id
  name    = "teamspeak.wizardnet.100625.lol"
  type    = "A"
  ttl     = 300
  records = [aws_eip.lb.public_ip]
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.public_zone.zone_id
  name    = "www.wizardnet.100625.lol"
  type    = "CNAME"
  ttl     = 300
  records = ["wizardnet.100625.lol"]
}

resource "aws_route53_record" "app_server_record" {
  zone_id = data.aws_route53_zone.public_zone.zone_id
  name    = "appserver.wizardnet.100625.lol"
  type    = "A"
  ttl     = 300
  records = [aws_instance.app_server.private_ip]
}