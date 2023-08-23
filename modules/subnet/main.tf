resource "aws_subnet" "main" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.public_ip

  tags = merge(
    { Name = "${var.name}" },
    var.tags
  )
}