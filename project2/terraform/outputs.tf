output "ec2_instances_ids" {
  description = "All EC2 instance IDs"
  value       = module.ec2_instances[*].instance_id
}

output "ec2_instance_public_ips" {
  description = "All EC2 instance public IPs"
  value       = module.ec2_instances[*].instance_public_ip
}

output "ec2_instance_private_ips" {
  description = "All EC2 instance private IPs"
  value       = module.ec2_instances[*].instance_private_ip
}

output "ec2_ssh_key_paths" {
  description = "SSH private key paths (one per instance)"
  value       = module.ec2_instances[*].ssh_private_key_path
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}
