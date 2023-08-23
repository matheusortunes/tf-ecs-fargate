variable "tags" {
  type = map(string)
}

variable "role_arn" {
  type = string
}

variable "bucket" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "branch" {
  type = string
}

variable "codebuild_project_name" {
  type = string
}

variable "codepipeline_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "env" {
  type = string
}

variable "assume_role" {
  type = string
}

variable "kms_arn" {
  type = string
}