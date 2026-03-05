output "combined_message" {
  value = <<-EOT

  To login Stirling PDF page: 
  http://${aws_instance.app_server.public_ip}:9080/login


  public_ip:
  ${aws_instance.app_server.public_ip}
  

EOT
}
