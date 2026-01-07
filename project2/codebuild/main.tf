terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "website_codebuild" {
  source = "./modules/codebuild_project"

  project_name         = "website-build"
  github_repo_url      = "https://github.com/arkb2023/website.git"
  buildspec_path       = "buildspec.yml"
  aws_region           = var.aws_region
  github_token_secret_arn = var.github_token_secret_arn
  dockerhub_token_secret_arn = var.dockerhub_token_secret_arn
}
