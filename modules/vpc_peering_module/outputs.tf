output "private_ip_mumbai" {
  value       = aws_instance.mumbai_instance.private_ip
  description = "Private IP of EC2 instance in Mumbai region"
}

output "private_ip_virginia" {
  value       = aws_instance.n-virginia_instance.private_ip
  description = "Private IP of EC2 instance in N-Virginia region"
}

output "vpc_peering_status" {
  value       = aws_vpc_peering_connection.vpc_peering.accept_status
  description = "Status of the VPC Peering Connection"
}
