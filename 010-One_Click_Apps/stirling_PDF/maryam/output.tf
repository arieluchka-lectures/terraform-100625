
output "vpc_id" {
 value = aws_vpc.stirling_pdf_vpc.id
}
  
output "stirling_public_ip" {
  value = aws_instance.stirling_pdf_app.public_ip
}



output "combined_message" {
  value = <<-EOT


Connect to the EC2 instance:
  ssh ec2-user@${aws_instance.stirling_pdf_app.public_ip}

Open in browser:
  http://${aws_instance.stirling_pdf_app.public_ip}:8080
EOT
}
