output "server_public_id" {
  value = aws_eip.n8n-eip.public_ip
}

output "current_time_function" {
  value = timestamp()
}

output "instructions" {
  value = <<-EOT
        Welcome!
        Connect to the web service through the following link (maybe needs 3-5 minutes to load)

        http://${aws_eip.n8n-eip.public_ip}:5678/
    EOT
}