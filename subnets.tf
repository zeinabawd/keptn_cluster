######  two subnets in two AZ for HA  ######
######  subnet1 ######
resource "aws_subnet" "eks_subnet1" {
  vpc_id                  = aws_vpc.eks.id
  availability_zone       = "us-east-1a"
  cidr_block              = var.subnet1_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.subnet1_name}"
  }
}

######  subnet2 ######
resource "aws_subnet" "eks_subnet2" {
  vpc_id                  = aws_vpc.eks.id
  availability_zone       = "us-east-1b"
  cidr_block              = var.subnet2_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.subnet2_name}"
  }
}
