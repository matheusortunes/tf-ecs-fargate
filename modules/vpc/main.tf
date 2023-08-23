# VPC - This VPC will be the same for both environment PRD and HML
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    { Name = "vpc-${var.project_name}-${var.env}" },
    var.tags
  )
}


# IGW - This will be used to grant access to the rest of the VPC to the internet
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    { Name = "ig-${var.project_name}-${var.env}" },
    var.tags
  )
}



