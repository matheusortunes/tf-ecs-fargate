variable "tags" {
  type = map(string)
}

variable "codebuild_project_name" {
  type = string
}

variable "buildspec_path" {
  type = string
}

variable "codebuild_service_role" {
  type = string
}

variable "description" {
  type = string
}

variable "compute_type" {
  type = string
}

variable "image" {
  type = string
}

variable "type" {
  type = string
}

variable "privileged" {
  type = string
}