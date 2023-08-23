variable "tags" {
  type = map(string)

  default = {
    "project"   = "my-project"
    "terraform" = "true"
    "env"       = "ENVIRONMENT"
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "role-ENVIRONMENT"
}

variable "project_name" {
  type    = string
  default = "my-project"
}

variable "env" {
  type    = string
  default = "ENVIRONMENT"
}

variable "devops_account_id" {
  type    = string
  default = "23456789012"
}

#--------------------------------------------
# Variables to deploy VPC and Subnet modules
#--------------------------------------------
variable "availability_zones" {
  type = map(string)
  default = {
    a = "us-east-1a"
    b = "us-east-1b"
    c = "us-east-1c"
  }
  description = "Define subnets AZs"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.62.0.0/16"
  description = "Define VPC CIDR block"
}

variable "public_subnets" {
  type = map(object({
    name              = string
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    "pub-sb-a" = {
      name              = "pub-sb-ENVIRONMENT-a"
      cidr_block        = "10.62.0.0/24"
      availability_zone = "us-east-1a"
    }
    "pub-sb-b" = {
      name              = "pub-sb-ENVIRONMENT-b"
      cidr_block        = "10.62.1.0/24"
      availability_zone = "us-east-1b"
    }
  }
}

variable "private_subnets" {
  type = map(object({
    name              = string
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    "pvt-sb-a" = {
      name              = "pvt-sb-ENVIRONMENT-a"
      cidr_block        = "10.62.2.0/24"
      availability_zone = "us-east-1a"
    }
    "pvt-sb-b" = {
      name              = "pvt-sb-ENVIRONMENT-b"
      cidr_block        = "10.62.4.0/24"
      availability_zone = "us-east-1b"
    }
    "pvt-sb-db-a" = {
      name              = "pvt-sb-ENVIRONMENT-a"
      cidr_block        = "10.62.3.0/24"
      availability_zone = "us-east-1a"
    }
    "pvt-sb-db-b" = {
      name              = "pvt-sb-ENVIRONMENT-db-b"
      cidr_block        = "10.62.5.0/24"
      availability_zone = "us-east-1b"
    }
  }
}