output "ec2_instances_ids" {
  description = "Map: worker name → EC2 instance ID"
  value = { 
    for k, m in module.ec2_instances : k => m.instance_id 
  }
}

output "ec2_instance_public_ips" {
  description = "Map: worker name → public IP"
  value = { 
    for k, m in module.ec2_instances : k => m.instance_public_ip 
  }
}

output "ec2_instance_private_ips" {
  description = "Map: worker name → private IP"
  value = { 
    for k, m in module.ec2_instances : k => m.instance_private_ip 
  }
}

output "ec2_ssh_key_paths" {
  description = "Map: worker name → SSH private key path"
  value = { 
    for k, m in module.ec2_instances : k => m.ssh_private_key_path 
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}
