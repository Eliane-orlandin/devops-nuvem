# Subnets Privadas
resource "aws_subnet" "private" {
  count                   = length(var.vpc.private_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.vpc.private_subnets[count.index].cidr_block
  availability_zone       = var.vpc.private_subnets[count.index].availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = var.vpc.private_subnets[count.index].name
    Type = "Private"
  }
}

# Elastic IP para o NAT Gateway
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "dvn-nat-eip"
  }
}

# NAT Gateway único na Subnet Pública 1
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "dvn-nat-gateway"
  }

  depends_on = [aws_internet_gateway.this]
}

# Route Table Privada (encaminha 0.0.0.0/0 para o NAT Gateway único)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "dvn-private-route-table"
  }
}

# Associação das Subnets Privadas à Route Table Privada
resource "aws_route_table_association" "private" {
  count          = length(var.vpc.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
