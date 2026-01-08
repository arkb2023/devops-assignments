# terraform init  # Pre-requisite: downloads providers to .terraform/providers
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Default Mumbai provider (ap-south-1)
# provider "aws" {
#   alias  = "Mumbai"
#   region = "ap-south-1"
# }
