locals {
  apache_user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2
    systemctl enable apache2
    systemctl start apache2
    echo "<h1>Apache installed via Terraform Stage 5</h1>" > /var/www/html/index.html
  EOF
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  az                 = "us-east-2a"
  name               = "stage5-vpc"
}

module "ec2_instance" {
  source = "../../modules/ec2"

  instance_name           = "stage5-ec2"
  instance_type           = var.instance_type
  my_ip                   = var.my_ip
  create_eip              = true
  vpc_security_group_ids  = []
  subnet_id               = module.vpc.public_subnet_id
  vpc_id                  = module.vpc.vpc_id
  user_data               = local.apache_user_data   # PASS SCRIPT
}

# To create environments/a05/instance_ip.txt with the IPs after apply.
resource "local_file" "instance_ip" {
  filename = "${path.module}/instance_ip.txt"
  content  = "stage5-ec2 public IP: ${module.ec2_instance.instance_public_ip}\nElastic IP: ${module.ec2_instance.eip_public_ip}\n"
}
