
output "vpc_id" {
  description = "SonarQube VPC ID"
  value       = aws_vpc.sonarqube_vpc.id
}

output "public_subnet_id" {
  description = "SonarQube public subnet ID"
  value       = aws_subnet.sonarqube_public.id
}

output "security_group_id" {
  description = "SonarQube security group ID"
  value       = aws_security_group.sonarqube_sg.id
}

output "instance_id" {
  description = "SonarQube EC2 instance ID"
  value       = aws_instance.sonarqube_server.id
}

output "elastic_ip" {
  description = "Stable public IPv4 address for SSH and DNS"
  value       = aws_eip.sonarqube_eip.public_ip
}

output "ssh_command" {
  description = "SSH command for your Ubuntu instance"
  value       = "ssh -i <PATH_TO_PRIVATE_KEY> ubuntu@${aws_eip.sonarqube_eip.public_ip}"
}

output "sonarqube_url" {
  description = "SonarQube URL using its default port"
  value       = "http://${aws_eip.sonarqube_eip.public_ip}:9000"
}
