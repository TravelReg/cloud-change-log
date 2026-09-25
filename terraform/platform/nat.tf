resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "ccl-dev-nat"
  }
}

resource "aws_nat_gateway" "app" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["a"].id

  depends_on = [aws_route.public_internet]

  tags = {
    Name = "ccl-dev-nat"
  }
}

resource "aws_route" "app_outbound" {
  route_table_id         = aws_route_table.app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.app.id
}