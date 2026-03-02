
output "vpc_id" {
 value = aws_vpc.stirling_pdf_vpc.id
}
  
output "stirling_public_ip" {
  value = aws_instance.stirling_pdf_app.public_ip
}



output "combined_message" {
  value = <<-EOT
Start-Service ssh-agent
ssh-add ${local_file.private_key.filename}

Connect to the EC2 instance:
  ssh ec2-user@${aws_instance.stirling_pdf_app.public_ip}

Open in browser:
  http://${aws_instance.stirling_pdf_app.public_ip}:8080
EOT
}
# sudo yum update -y
# sudo yum install -y docker
# sudo service docker start
# sudo usermod -aG docker ec2-user
# mkdir -p ~/stirling-data
# docker run -d \
#   --name stirling-pdf \
#   -p 8080:8080 \
#   -v ~/stirling-data:/configs \
#   --restart unless-stopped \
#   stirlingtools/stirling-pdf:latest