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

# Default Ohio provider (us-east-2)
provider "aws" {
  alias  = "ohio"
  region = "us-east-2"
}

# N. Virginia provider (us-east-1)
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
