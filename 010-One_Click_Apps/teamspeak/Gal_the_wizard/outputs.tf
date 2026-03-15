
output "bastion_ip_address" {
  value = aws_instance.bastion.public_ip

}

output "vpc_id" {
  value = aws_vpc.main.id
}


output "private_ip_of_app_server" {
  value = aws_instance.app_server.private_ip
}

output "connection_message_to_the_user" {
  value = "commiting proxy via bastion host to app server using: ssh-add ${local_file.private_key.filename} ssh -J ec2-user@${aws_instance.bastion.public_ip} ec2-user@${aws_instance.app_server.private_ip}"

}

output "NLB" {
  value = aws_lb.loadbalancer.dns_name
}
output "NLB_id" {
  value = aws_lb.loadbalancer.id
}
output "NLB_ip" {
  value = aws_eip.lb.public_ip

}