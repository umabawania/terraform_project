output "public_instance_public_ip" {
  description = "Public IP of the public EC2 instance"
  value       = aws_instance.public_instance.public_ip
}

output "public_instance_private_ip" {
  description = "Private IP of the public EC2 instance"
  value       = aws_instance.public_instance.private_ip
}

output "bastion_instance_public_ip" {
  description = "Public IP of the Bastion EC2 instance"
  value       = aws_instance.Bastion_host_instance.public_ip
}

output "bastion_instance_private_ip" {
  description = "Private IP of the Bastion EC2 instance"
  value       = aws_instance.Bastion_host_instance.private_ip
}
