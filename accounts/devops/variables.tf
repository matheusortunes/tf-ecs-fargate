variable "tags" {
  type = map(string)

  default = {
    "project"   = "my-project"
    "terraform" = "true"
    "env"       = "devops"
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "role-devops"
}

variable "project_name" {
  type    = string
  default = "my-project"
}

variable "env" {
  type    = string
  default = "devops"
}

variable "environment_account_id" {
  type    = string
  default = "012345678901"
}

#--------------------------------------------
# Variables to deploy S3 module
#--------------------------------------------

variable "s3" {
  description = "List of buckets for my-project with no public access"

  default = {
    "codepipeline" = {}
  }
}

#--------------------------------------------
# Variables to deploy CICD Modules
#--------------------------------------------

variable "repositories" {
  type = map(object({
    description = string
  }))
  default = {
    "my-project.terraform-iac" = {
      description = "Infrastructure as Code (Terraform) Repository"
    }
    "my-project.application" = {
      description = "my-project Application Repository"
    }
  }
}

variable "build-projects" {
  type = map(object({
    description    = string
    buildspec_file = string
    compute_type   = string
    image          = string
    type           = string
    privileged     = string
  }))
  default = {
    "ecs-environment-build-job" = {
      description    = "ECS Build image and update task"
      buildspec_file = "ecs-environment-build-job-buildspec.yaml"
      compute_type   = "BUILD_GENERAL1_MEDIUM"
      image          = "aws/codebuild/standard:5.0"
      type           = "LINUX_CONTAINER"
      privileged     = true
    }
  }
}


variable "pipelines-ecs" {
  type = map(object({
    build_project = string
    repo_name     = string
    branch        = string
    env           = string
    service_name  = string
    assume_role   = string
  }))
  default = {
    "ecs-environment-build-job" = {
      repo_name     = "my-project.api"
      build_project = "ecs-environment-build-job-build"
      branch        = "ENVIRONMENT_BRANCH"
      env           = "ENVIRONMENT"
      service_name  = "SERVICE_NAME"
      assume_role   = "arn:aws:iam::12345678901:role/CICD-Ecs-Role-ENVIRONMENT"
    }
  }
}

#--------------------------------------------
# Variables to deploy ECR Module
#--------------------------------------------

variable "ecr" {
  type = list(any)
  default = [
    "devops/helloworld",
    "auto"
  ]
}

#--------------------------------------------
# Variables to deploy Approval Rules
#--------------------------------------------

variable "role_approve_admin" {
  type = string
  default = ADMIN_ACCOUNT_ROLE
}