variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"  # Ohio
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "hello-ec2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "my_ip" {
  description = "Your IP for SSH access"
  type        = string
}
