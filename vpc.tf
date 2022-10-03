resource "aws_vpc" "eks" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.vpc_name}"
  }
}