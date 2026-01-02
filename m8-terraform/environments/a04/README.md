<div align="center">

![Executed from Bash Prompt](https://img.shields.io/badge/Executed-Bash%20Prompt-green?logo=gnu-bash)
![Infrastructure as Code](https://img.shields.io/badge/IaC-Terraform-blue?logo=terraform)
![AWS Provisioned](https://img.shields.io/badge/Cloud-AWS-orange?logo=amazon-aws)
![Verified via AWS Console](https://img.shields.io/badge/Verified-AWS%20Console-yellow?logo=amazon-aws)
![Status: Completed](https://img.shields.io/badge/Status-Completed-brightgreen)

</div>

## Module 8: Terraform Assignment - 4

Tasks To Be Performed:  
1. Destroy the previous deployments  
2. Create a VPC with the required components using Terraform  
3. Deploy an EC2 instance inside the VPC  

---

### Solution Overview
Assignment-4 solution builds on the reusable `ec2` module from [Assignment 3](../a03/README.md), adding custom VPC networking:

- New vpc module: VPC (10.0.0.0/16) + public subnet + IGW + route table
- Enhanced ec2 module: Accepts vpc_id + subnet_id inputs
- Security group created in VPC
- EIP + SSH: Full connectivity maintained
- [`modules/vpc/`](../../modules/vpc/): Reusable vpc module
- [`modules/ec2/`](../../modules/ec2/): Reusable ec2 module
- [`environments/a04/`](../a04/): Environment for Assignment 4
- [`environments/a03/`](../a03/): Environment for Assignment 3
- [`environments/a02/`](../a02/): Environment for Assignment 2
- [`environments/a01/`](../a01/): Environment for Assignment 1
- Outputs: vpc_id, subnet_id, elastic_ip, instance_ip

---

**Repo Structure**:

<pre>
m8-terraform/                               # Module 8 assignments
├── modules                                 # terraform modules
# ----------------- vpc module -----------------------------------------------
├── vpc/                                    # Reusable VPC module
│   ├── main.tf                             # VPC core resources: VPC, public subnet, IGW, route table, subnet association
│   ├── outputs.tf                          # Exports: vpc_id, public_subnet_id
│   ├── variables.tf                        # Variables/Defaults
│   ├── versions.tf                         # Provider constraints
# ----------------- ec2 module -----------------------------------------------
│   ├── ec2                                 # Reusable EC2 module
│   │   ├── main.tf                         # EC2 + SG + SSH key logic
│   │   ├── outputs.tf                      # instance_ip, ssh_private_key_path
│   │   ├── variables.tf                    # instance_name, my_ip, vpc_id, user_data
│   │   └── versions.tf                     # aws/tls/local providers
├── environments
# -----------------Assignment 4 environment code ------------------------------
│   ├── a04                                 # Assignment 4: Custom VPC + EC2
│   │   ├── README.md                       # Setup and execution instructions
│   │   ├── images                          # AWS console screenshots folder
│   │   │   ├── 01-vpc.png
│   │   │   └── 02-ec2-instance.png
│   │   ├── main.tf                         # Calls ec2 module
│   │   ├── outputs.tf                      # Outputs
│   │   ├── terraform.tfvars.example        # my_ip=<client-ip>/32          
│   │   ├── variables.tf                    # Variables/defaults
│   │   └── versions.tf                     # Provider constraints
# -----------------Assignment 3 environment code ------------------------------
│   ├── a03                                   # Assignment 3: EC2 in Ohio and N.Virginia
│   │   ├── README.md                         # Setup and execution instructions
│   │   ├── images                            # AWS console screenshots folder
│   │   │   ├── 01-ec2-instance-virginia.png
│   │   │   └── 02-ec2-instance-ohio.png
│   │   ├── main.tf                           # Calls ec2 module
│   │   ├── outputs.tf                        # Outputs: instance_ip, elastic_ip for both regions
│   │   ├── terraform.tfvars.example          # my_ip=<client-ip>/32                  
│   │   ├── variables.tf                      # Variables/defaults
│   │   └── versions.tf                       # Provider constraints
# -----------------Assignment 2 environment code ------------------------------
│   ├── a02                                 # Assignment 2: 'Elastic IP'
│   │   ├── README.md                       # Setup and execution instructions
│   │   ├── images                          # AWS console screenshots folder
│   │   │   └── 01-ec2-instance.png
│   │   ├── main.tf                         # Calls ec2 module
│   │   ├── outputs.tf                      # instance_ip, instance_id
│   │   ├── terraform.tfvars.example        # my_ip=<client-ip>/32
│   │   ├── variables.tf                    # aws_region=Ohio, instance_name=hello-ec2
│   │   └── versions.tf                     # Provider constraints
# -----------------Assignment 1 environment code ------------------------------
│   ├── a01                                 # Assignment 1: Ohio default subnet
│   │   ├── README.md                       # Setup and execution instructions
│   │   ├── main.tf                         # Calls ec2 module
│   │   ├── outputs.tf                      # instance_ip, instance_id
│   │   ├── terraform.tfvars.example        # my_ip=<client-ip>/32
│   │   ├── variables.tf                    # aws_region=Ohio, instance_name=hello-ec2
│   │   ├── versions.tf                     # Provider constraints
│   │   ├── images                          # AWS console screenshots folder
│   │   │   ├── 01-ec2-instance.png
│   │   │   ├── 02-security-group.png
│   │   │   ├── 03-default-vpc.png
│   │   │   ├── 04-terraform-output.png
│   │   │   ├── 05-terraform-ssh-key.png
│   │   │   └── 06-ec2-key-pair.png
</pre>

---

### Prereqquisite
- Provision resources as desribed in [Assignment 3](../a03/README.md)

---

### 1. Destroy the previous deployment
  ```bash
  cd environments/a03
  terraform destroy -auto-approve
  
  # Output
  module.hello_virginia.local_file.private_key_pem: Destroying... [id=c361c128526a1e023d30bb8e9cafd8f02bb58ef4]
  module.hello_ohio.local_file.private_key_pem: Destroying... [id=38d519e2c2fa5cae284409d36d33d8c7cc524a13]
  module.hello_virginia.local_file.private_key_pem: Destruction complete after 0s
  module.hello_ohio.local_file.private_key_pem: Destruction complete after 0s
  module.hello_ohio.aws_eip.this[0]: Destroying... [id=eipalloc-00240bc952331eda1]
  module.hello_virginia.aws_eip.this[0]: Destroying... [id=eipalloc-0a6bfdb81891d8e42]
  module.hello_ohio.aws_eip.this[0]: Still destroying... [id=eipalloc-00240bc952331eda1, 00m11s elapsed]
  module.hello_virginia.aws_eip.this[0]: Still destroying... [id=eipalloc-0a6bfdb81891d8e42, 00m11s elapsed]
  module.hello_ohio.aws_eip.this[0]: Destruction complete after 14s
  module.hello_ohio.aws_instance.this: Destroying... [id=i-0c494c68e4787908a]
  module.hello_virginia.aws_eip.this[0]: Destruction complete after 14s
  module.hello_virginia.aws_instance.this: Destroying... [id=i-02969dfc4714ace4d]
  module.hello_ohio.aws_instance.this: Still destroying... [id=i-0c494c68e4787908a, 00m10s elapsed]
  module.hello_virginia.aws_instance.this: Still destroying... [id=i-02969dfc4714ace4d, 00m10s elapsed]
  module.hello_ohio.aws_instance.this: Still destroying... [id=i-0c494c68e4787908a, 00m20s elapsed]
  module.hello_virginia.aws_instance.this: Still destroying... [id=i-02969dfc4714ace4d, 00m20s elapsed]
  module.hello_ohio.aws_instance.this: Still destroying... [id=i-0c494c68e4787908a, 00m31s elapsed]
  module.hello_virginia.aws_instance.this: Still destroying... [id=i-02969dfc4714ace4d, 00m31s elapsed]
  module.hello_ohio.aws_instance.this: Destruction complete after 32s
  module.hello_ohio.aws_key_pair.this_key: Destroying... [id=hello-ohio-key]
  module.hello_ohio.aws_security_group.ec2_sg: Destroying... [id=sg-0cc158a8ebe9f5815]
  module.hello_ohio.aws_key_pair.this_key: Destruction complete after 1s
  module.hello_ohio.tls_private_key.this_key: Destroying... [id=2ba50320814d822e114434ce4aefad468781bfa2]
  module.hello_ohio.tls_private_key.this_key: Destruction complete after 0s
  module.hello_ohio.aws_security_group.ec2_sg: Destruction complete after 2s
  module.hello_virginia.aws_instance.this: Still destroying... [id=i-02969dfc4714ace4d, 00m41s elapsed]
  module.hello_virginia.aws_instance.this: Still destroying... [id=i-02969dfc4714ace4d, 00m51s elapsed]
  module.hello_virginia.aws_instance.this: Still destroying... [id=i-02969dfc4714ace4d, 01m02s elapsed]
  module.hello_virginia.aws_instance.this: Destruction complete after 1m4s
  module.hello_virginia.aws_security_group.ec2_sg: Destroying... [id=sg-0ebf24b644a4babb6]
  module.hello_virginia.aws_key_pair.this_key: Destroying... [id=hello-virginia-key]
  module.hello_virginia.aws_key_pair.this_key: Destruction complete after 1s
  module.hello_virginia.tls_private_key.this_key: Destroying... [id=4d3388521698803c5d3537215a17f691f0d7e1e5]
  module.hello_virginia.tls_private_key.this_key: Destruction complete after 0s
  module.hello_virginia.aws_security_group.ec2_sg: Destruction complete after 2s

  Destroy complete! Resources: 12 destroyed.
  ```

---

### 2. Create a VPC with EC2 instance

- Create `terraform.tfvars` and set following information in it
  ```bash
  cp terraform.tfvars.example terraform.tfvars
  # Edit terraform.tfvars:
  my_ip      = "<client-ip>/32" # Set client public IP for SSH access
  ```

- Create Custom VPC and EC2 with Terraform 
  ```bash
  cd environments/a04
  terraform init
  terraform validate
  terraform plan -out=tfplan
  terraform apply -auto-approve tfplan

  # Output
  ...<snip>...
  Outputs:

  elastic_ip = "3.134.144.76"
  instance_ip = "3.145.152.18"
  subnet_id = "subnet-0e8e18864d2dbbf59"
  vpc_id = "vpc-0bc34b4d581abdc79"
  ```

- Custom VPC `vpc-0bc34b4d581abdc79`  
  ![Custom VPC](./images/01-vpc.png)

- EC2 instance `3.134.144.76` in Custom VPC `vpc-0bc34b4d581abdc79`  
  ![EC2 instance in custom VPC](./images/02-ec2-instance.png)

---