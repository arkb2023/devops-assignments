output "project_name" {
  value = aws_codebuild_project.this.name
}

output "service_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}
