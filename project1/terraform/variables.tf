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
  description = "EC2 instance type per instance"
  type        = map(string)
  default     = {
    instance1 = "t3.micro"
    instance2 = "t3.small"
    instance3 = "t3.micro"
    instance4 = "t3.micro"
  }
}

variable "instance_names" {
  description = "EC2 instance name per instance"
  type        = map(string)
  default     = {
    instance1 = "control"
    instance2 = "jenkins"
    instance3 = "prod"
    instance4 = "test"
  }
}