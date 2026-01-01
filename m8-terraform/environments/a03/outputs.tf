output "ohio_instance_ip" {
  description = "Public IP of hello-ohio"
  value       = module.hello_ohio.instance_public_ip
}

output "ohio_elastic_ip" {
  description = "Elastic IP of hello-ohio"
  value       = module.hello_ohio.eip_public_ip
}

output "virginia_instance_ip" {
  description = "Public IP of hello-virginia"
  value       = module.hello_virginia.instance_public_ip
}

output "virginia_elastic_ip" {
  description = "Elastic IP of hello-virginia"
  value       = module.hello_virginia.eip_public_ip
}
