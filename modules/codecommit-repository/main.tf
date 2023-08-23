resource "aws_codecommit_repository" "repo" {
  repository_name = var.repository_name
  description     = var.description
  #default_branch = "master"
}