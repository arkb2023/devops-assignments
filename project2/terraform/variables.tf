variable "my_ip" {
  description = "Your IP for SSH access"
  type        = string
}

variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-south-1"
  validation {
    condition     = contains(["ap-south-1"], var.aws_region)
    error_message = "Region must be ap-south-1"
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "instance_types" {
  description = "EC2 instance type per worker"
  type        = map(string)
  default     = {
    worker1 = "t3.small"
    worker2 = "t3.micro"
    worker3 = "t3.small"
    worker4 = "t3.micro"
  }
}