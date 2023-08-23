
variable "vpc_cidr_block" {
  type        = string
  description = "Define VPC CIDR block"
}

variable "project_name" {
  type        = string
  description = "Define Project Name"
}

variable "env" {
  type = string
}

variable "tags" {
  type = map(string)
}