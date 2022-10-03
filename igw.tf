resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks.id

  tags = {
    Name = "${var.igw_name}"
  }
}