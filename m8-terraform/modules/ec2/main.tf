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

# Ubuntu 22.04 AMI (Ohio)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name_prefix = "${var.instance_name}-sg"
  vpc_id      = var.vpc_id

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
  
  # a04
  vpc_security_group_ids = concat([aws_security_group.ec2_sg.id], var.vpc_security_group_ids)
  
  subnet_id = var.subnet_id
  
  # a05
  user_data = var.user_data

  metadata_options {
    http_tokens                 = "optional"  # IMDSv1 + v2
    http_endpoint               = "enabled"
    instance_metadata_tags      = "enabled"
    http_put_response_hop_limit = 2
  }
  
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
