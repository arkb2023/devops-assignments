# modules/ec2/versions.tf already declares aws, tls, local providers as before.

# Ohio instance
module "hello_ohio" {
  source = "../../modules/ec2"

  providers = {
    aws   = aws.ohio    # Use "ohio" AWS provider (us-east-2)
    tls   = tls
    local = local
  }

  instance_name         = "hello-ohio"
  instance_type         = var.instance_type
  my_ip                 = var.my_ip
  create_eip            = true
  vpc_security_group_ids = []
  subnet_id             = ""   # default subnet in us-east-2
}

# Virginia instance
module "hello_virginia" {
  source = "../../modules/ec2"

  providers = {
    aws   = aws.virginia    # Use "virginia" AWS provider (us-east-1)
    tls   = tls             
    local = local
  }

  instance_name         = "hello-virginia"
  instance_type         = var.instance_type
  my_ip                 = var.my_ip
  create_eip            = true
  vpc_security_group_ids = []
  subnet_id             = ""   # default subnet in us-east-1
}
