terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.57"
    }
  }
}

provider "aws" {
  profile = "role-ENVIRONMENT"
  region  = "us-east-1"
}