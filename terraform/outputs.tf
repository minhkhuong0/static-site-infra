# output "instance_hostname" {
#   description = "Private DNS name of the EC2 instance."
#   value       = aws_instance.app_server.private_dns
# }

output "instance_id" {
  description = "Instance ID of the EC2 instance."
  value       = aws_instance.app_server.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.app_server.public_ip
}
