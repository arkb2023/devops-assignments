# VPC + public subnet
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  az                 = "us-east-2a"
  name               = "stage4-vpc"
}

# EC2 inside VPC's public subnet
module "ec2_instance" {
  source = "../../modules/ec2"

  instance_name          = "stage4-ec2"
  instance_type          = var.instance_type
  my_ip                  = var.my_ip
  create_eip             = true
  vpc_security_group_ids = []              # module creates its own SG
  subnet_id              = module.vpc.public_subnet_id
  vpc_id                 = module.vpc.vpc_id
}
