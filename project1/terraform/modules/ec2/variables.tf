variable "instance_name" {
  description = "EC2 instance name tag"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "my_ip" {
  description = "IP for SSH access (CIDR)"
  type        = string
  validation {
    condition     = can(cidrhost(var.my_ip, 0))
    error_message = "Must be valid CIDR (e.g., '203.0.113.1/32')."
  }
}

variable "vpc_id" {
  description = "VPC ID where EC2 and its security group will be created"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Target subnet ID (empty = default subnet)"
  type        = string
  default     = ""
}

variable "create_eip" {
  description = "Attach Elastic IP"
  type        = bool
  default     = false
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs (overrides default)"
  type        = list(string)
  default     = []
}
