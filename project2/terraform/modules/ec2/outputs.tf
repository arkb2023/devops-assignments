output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "instance_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.this.public_ip
}

output "instance_private_ip" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "EC2 security group ID"
  value       = aws_security_group.ec2_sg.id
}

output "ssh_private_key_path" {
  description = "Path to auto-generated SSH private key"
  value       = local_file.private_key_pem.filename
}

output "eip_public_ip" {
  description = "Elastic IP address attached to the instance"
  value       = try(aws_eip.this[0].public_ip, null)
}
