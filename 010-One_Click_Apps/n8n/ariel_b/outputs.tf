output "server_public_id" {
  value = aws_eip.n8n-eip.public_ip
}

output "instructions" {
  value = <<-EOT
        Welcome!
        Connect to the web service through the server_public_id and port 5678 (maybe needs 3-5 minutes to load)
    EOT
}