variable "project_name" {
  type = string
}

variable "github_repo_url" {
  type = string
}


variable "buildspec_path" {
  type    = string
  default = "buildspec.yml"
}

variable "aws_region" {
  type = string
}

variable "github_token_secret_arn" {
  type = string
}

variable "dockerhub_token_secret_arn" {
  type = string
}

