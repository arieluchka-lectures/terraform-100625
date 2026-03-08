output "combined_message" {
  value = <<-EOT

  To login Stirling PDF page: 
  http://${aws_instance.app_server.public_ip}:${var.app_port}/login


  public_ip:
  ${aws_instance.app_server.public_ip}
  

EOT
}
