resource "aws_codebuild_project" "project" {
  name          = var.codebuild_project_name
  description   = var.description
  build_timeout = "15"
  service_role  = var.codebuild_service_role

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.compute_type
    image           = var.image
    type            = var.type
    privileged_mode = var.privileged
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file(var.buildspec_path)
  }

  tags = var.tags
}