module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  az                 = var.availability_zones
  name               = "project1-vpc"
}

module "ec2_instances" {
  source = "./modules/ec2"
  
  for_each              = { for i in [1,2,3,4] : "instance${i}" => i }
  #instance_name         = each.key
  instance_name         = var.instance_names[each.key]  # Per-instance override
  instance_type         = var.instance_types[each.key]  # Per-instance override
  my_ip                 = var.my_ip
  subnet_id             = module.vpc.public_subnet_ids[each.value % 3]
  vpc_id                = module.vpc.vpc_id
  
  depends_on = [module.vpc]
}