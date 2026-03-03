output "server_public_id" {
  value = aws_eip.n8n-eip.public_ip
}