output "arn" {
  value = aws_codecommit_repository.repo.arn
}

output "name" {
  value = aws_codecommit_repository.repo.repository_name
}