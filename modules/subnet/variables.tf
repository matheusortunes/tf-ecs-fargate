variable "vpc_id" {
  type        = string
  description = "Define VPC CIDR block"
}

variable "tags" {
  type = map(string)
}


variable "cidr_block" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "name" {
  type = string
}

variable "public_ip" {
  type = bool
}