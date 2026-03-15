output "instance_id" {
  value = aws_instance.nextcloud.id
}

output "elastic_ip" {
  value = aws_eip.nextcloud_eip.public_ip
}

output "service_url" {
  value = "http://${aws_eip.nextcloud_eip.public_ip}"
}

output "ssm_command" {
  value = "aws ssm start-session --target ${aws_instance.nextcloud.id} --region ${data.aws_region.current.name}"
}

output "ssh_command" {
  value = "ssh ec2-user@${aws_eip.nextcloud_eip.public_ip}"
}