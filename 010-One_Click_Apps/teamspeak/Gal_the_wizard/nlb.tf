# ============================================
# Load Balancer
# ============================================
resource "aws_lb" "loadbalancer" {
  name               = "app-server-lb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.loadbalancer.id]
  subnet_mapping {
    subnet_id     = aws_subnet.public.id
    allocation_id = aws_eip.lb.id
  }
  tags = {
    Name = "app-server-lb"
    Name = var.daily_date_tag
  }
}
# ============================================
# Target Group and Listeners
# ============================================

resource "aws_lb_target_group" "app_server_tg" {
  name     = "app-server-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group" "app_server_filetransfer_tg" {
  name     = "app-server-filetransfer-tg"
  port     = 30033
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group" "app_server_chat_tg" {
  name     = "app-server-chat-tg"
  port     = 10011
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group" "app_server_voice_tg" {
  name     = "app-server-voice-tg"
  port     = 9987
  protocol = "UDP"
  vpc_id   = aws_vpc.main.id
}



resource "aws_lb_listener" "console_listener" {
  port              = 80
  protocol          = "TCP"
  load_balancer_arn = aws_lb.loadbalancer.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_server_tg.arn
  }
}

resource "aws_lb_listener" "teamspeak_listener" {
  port              = 30033
  protocol          = "TCP"
  load_balancer_arn = aws_lb.loadbalancer.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_server_filetransfer_tg.arn
  }
}
resource "aws_lb_listener" "teamspeak_voice_listener" {
  port              = 9987
  protocol          = "UDP"
  load_balancer_arn = aws_lb.loadbalancer.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_server_voice_tg.arn
  }
}
resource "aws_lb_listener" "teamspeak_query_listener" {
  port              = 10011
  protocol          = "TCP"
  load_balancer_arn = aws_lb.loadbalancer.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_server_chat_tg.arn
  }
}

#============================================
# Target Group Attachments
#============================================

resource "aws_lb_target_group_attachment" "app_server_attachment" {
  target_group_arn = aws_lb_target_group.app_server_tg.arn
  target_id        = aws_instance.app_server.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "app_server_filetransfer_attachment" {
  target_group_arn = aws_lb_target_group.app_server_filetransfer_tg.arn
  target_id        = aws_instance.app_server.id
  port             = 30033
}
resource "aws_lb_target_group_attachment" "app_server_chat_attachment" {
  target_group_arn = aws_lb_target_group.app_server_chat_tg.arn
  target_id        = aws_instance.app_server.id
  port             = 10011
}
resource "aws_lb_target_group_attachment" "app_server_voice_attachment" {
  target_group_arn = aws_lb_target_group.app_server_voice_tg.arn
  target_id        = aws_instance.app_server.id
  port             = 9987
}