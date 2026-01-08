# Ubuntu 22.04 AMI
# data "aws_ami" "ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"]

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# data.aws_ami.ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  # Region filter
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# SSH Key Pair (Auto-generated)
resource "tls_private_key" "this_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this_key" {
  key_name   = "${var.instance_name}-key"
  public_key = tls_private_key.this_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.this_key.private_key_pem
  filename        = "${path.module}/${var.instance_name}-key.pem"
  file_permission = "0400"
}

resource "aws_security_group" "ec2_sg" {
  name_prefix = "${var.instance_name}-sg"
  vpc_id      = var.vpc_id
  description = "Security group for ${var.instance_name}"

  # SSH from specific IP
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  
  # HTTP from anywhere
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API
  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # VPC CIDR only
  }

  # Kubelet API
  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Internal traffic
  ingress {
    description = "Pod-to-Pod"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.instance_name}-sg"
  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this_key.key_name  # SSH Eenabled
  
  vpc_security_group_ids = concat([aws_security_group.ec2_sg.id], var.vpc_security_group_ids)
  
  subnet_id = var.subnet_id
  
  tags = {
    Name = var.instance_name
  }
}

resource "aws_eip" "this" {
  count = var.create_eip ? 1 : 0
  instance = aws_instance.this.id
  domain   = "vpc"
  
  tags = {
    Name = "${var.instance_name}-eip"
  }
}
