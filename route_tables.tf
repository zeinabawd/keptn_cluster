resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "${var.rtb_name}"
  }
}

###### routetables assosiation ######
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.eks_subnet1.id
  route_table_id = aws_route_table.public_rtb.id
}


resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.eks_subnet2.id
  route_table_id = aws_route_table.public_rtb.id
}