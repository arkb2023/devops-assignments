provider "aws" {
  region = var.aws_region
}

module "ec2_instance" {
  # Jump to modules/ec2/
  source = "../../modules/ec2"
  
  instance_name  = var.instance_name
  instance_type  = var.instance_type
  my_ip          = var.my_ip
  create_eip     = false
  vpc_security_group_ids = []
}
