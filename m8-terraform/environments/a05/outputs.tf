output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "Public subnet ID"
  value       = module.vpc.public_subnet_id
}

output "instance_ip" {
  description = "EC2 public IP"
  value       = module.ec2_instance.instance_public_ip
}

output "elastic_ip" {
  description = "Elastic IP"
  value       = module.ec2_instance.eip_public_ip
}
