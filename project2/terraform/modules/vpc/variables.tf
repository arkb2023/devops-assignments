variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# variable "public_subnet_cidr" {
#   description = "CIDR for the public subnet"
#   type        = string
#   default     = "10.0.1.0/24"
# }
variable "public_subnets" {
  description = "List of public subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

# variable "az" {
#   description = "AZ for public subnet"
#   type        = string
#   default     = "ap-south-1a"
# }
variable "az" {
  description = "AZs for subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "name" {
  description = "Base name for VPC resources"
  type        = string
  default     = "project2-vpc"
}

