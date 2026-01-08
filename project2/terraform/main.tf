module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  az                 = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  name               = "project2-vpc"
}

module "ec2_instances" {
  source = "./modules/ec2"
  
  count = 4

  instance_name           = "worker${count.index + 1}"
  instance_type           = var.instance_type
  my_ip                   = var.my_ip
  vpc_security_group_ids  = []
  
  # Round-robin across subnets (distribute across AZs)
  subnet_id               = module.vpc.public_subnet_ids[count.index % length(module.vpc.public_subnet_ids)]
  vpc_id                  = module.vpc.vpc_id
  
  depends_on = [module.vpc]
}