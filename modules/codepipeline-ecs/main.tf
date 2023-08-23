resource "aws_codepipeline" "codepipeline" {

  name     = var.codepipeline_name
  role_arn = var.role_arn

  artifact_store {
    type     = "S3"
    location = var.bucket

    encryption_key {
      id   = var.kms_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_artifact"]
      namespace        = "SourceVariables"
      configuration = {
        RepositoryName = var.repository_name
        BranchName     = var.branch
        #OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build-Image"
    action {
      name             = "Build"
      category         = "Build"
      provider         = "CodeBuild"
      version          = "1"
      owner            = "AWS"
      input_artifacts  = ["source_artifact"]
      output_artifacts = ["build_artifact"]
      configuration = {
        ProjectName = var.codebuild_project_name
        #EnvironmentVariables = "[{\"name\":\"Commit_Message\",\"value\":\"#{SourceVariables.CommitMessage}\",\"type\":\"PLAINTEXT\"}]"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_artifact"]
      version         = "1"

      configuration = {
        ClusterName       = "ecs-my-project-${var.env}"
        ServiceName       = var.service_name
        DeploymentTimeout = "15"
      }

      role_arn = var.assume_role
    }
  }

  tags = var.tags

}