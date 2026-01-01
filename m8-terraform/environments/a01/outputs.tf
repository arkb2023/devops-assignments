output "instance_ip" {
  description = "EC2 public IP"
  value       = module.ec2_instance.instance_public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2_instance.instance_id
}
