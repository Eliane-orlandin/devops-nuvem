# Subnets Públicas
resource "aws_subnet" "public" {
  count                   = length(var.vpc.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.vpc.public_subnets[count.index].cidr_block
  availability_zone       = var.vpc.public_subnets[count.index].availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = var.vpc.public_subnets[count.index].name
    Type = "Public"
  }
}

# Route Table Pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "dvn-public-route-table"
  }
}

# Associação das Subnets Públicas à Route Table Pública
resource "aws_route_table_association" "public" {
  count          = length(var.vpc.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
