output "public-ip" {
  value = aws_instance.terraform.public_ip 
}
output "key_pair" {
  value = aws_key_pair.key_pair-1.public_key
  sensitive = true
}
output "key-1.pem" {
  value = "${path.module}/example-key.pem"
}