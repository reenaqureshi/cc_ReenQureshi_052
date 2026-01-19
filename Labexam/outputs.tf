output "ec2_public_ip" {
  description = "EC2 instance public IP"
  value       = aws_instance.myapp_server.public_ip
}