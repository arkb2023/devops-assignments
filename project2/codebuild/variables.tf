variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "github_token_secret_arn" {
  type = string
}


variable "dockerhub_token_secret_arn" {
  type = string
}
