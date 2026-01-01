variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "az" {
  description = "AZ for public subnet"
  type        = string
  default     = "us-east-2a"
}

variable "name" {
  description = "Base name for VPC resources"
  type        = string
  default     = "stage4-vpc"
}
