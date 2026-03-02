output "combined_message" {
  value = <<-EOT

  To login Stirling PDF page: 
  http://${aws_instance.app_server.public_ip}:9080/login


  public_ip:
  ${aws_instance.app_server.public_ip}
  
  ssh server connect command:
  ssh -i ${local_file.private_key.filename} ec2-user@${aws_instance.app_server.public_ip}


EOT
}
