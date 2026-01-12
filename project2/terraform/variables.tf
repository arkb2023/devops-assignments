variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "my_ip" {
  description = "Your IP for SSH access"
  type        = string
}

variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-south-1"
  validation {
    condition     = contains(["ap-south-1", "us-east-1", "eu-west-1"], var.aws_region)
    error_message = "Region must be ap-south-1, us-east-1, or eu-west-1."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}