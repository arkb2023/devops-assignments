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
  description = "Security group for ${var.instance_name} - K3s + Jenkins"

  # ====== INGRESS RULES ======

  # SSH from specific IP
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  
  # HTTP - for Jenkins web UI and app
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  
  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Kubernetes API - VPC CIDR ONLY
  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # VPC CIDR only
  }

  # Kubelet API - VPC CIDR ONLY
  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "Pod-to-Pod (UDP)"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

 # Flannel VXLAN - VPC CIDR ONLY (inter-pod networking)
  ingress {
    description = "Flannel VXLAN"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  
  # Flannel WireGuard - VPC CIDR ONLY
  ingress {
    description = "Flannel WireGuard IPv4"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # etcd - VPC CIDR ONLY (K3s control plane)
  ingress {
    description = "etcd"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # NodePort range - Keep accessible but controlled
  ingress {
    description = "Kubernetes NodePort"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Pod-to-Pod traffic within cluster - VPC CIDR ONLY (TCP)
  ingress {
    description = "Pod-to-Pod (TCP)"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  
  # Jenkins
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # ====== EGRESS RULES ======

  # Allow SSH to other nodes (inter-node)  
  egress {
    description = "SSH to other nodes"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow DNS queries (required for pod DNS resolution)
  egress {
    description = "DNS"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS outbound for package downloads and external APIs
  egress {
    description = "HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP outbound (Docker Hub registry, etc.)
  egress {
    description = "HTTP outbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inter-cluster communication (TCP)
  egress {
    description = "Inter-node TCP"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Inter-cluster communication (UDP)
  egress {
    description = "Inter-node UDP"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this_key.key_name  # SSH Eenabled
  
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  
  subnet_id = var.subnet_id
  
  tags = {
    Name = var.instance_name
  }
  depends_on = [aws_security_group.ec2_sg]
}

resource "aws_eip" "this" {
  count = var.create_eip ? 1 : 0
  instance = aws_instance.this.id
  domain   = "vpc"
  
  tags = {
    Name = "${var.instance_name}-eip"
  }
}
