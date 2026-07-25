# Busca dinâmica da imagem Amazon Linux 2023 mais recente
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group para a Instância Pública (Bastion / Web)
resource "aws_security_group" "public_ec2" {
  name        = "dvn-public-ec2-sg"
  description = "Security Group para instancia publica EC2"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP de qualquer lugar"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS de qualquer lugar"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH de qualquer lugar"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Saida liberada"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dvn-public-ec2-sg"
  }
}

# Security Group para a Instância Privada (Application / Backend)
resource "aws_security_group" "private_ec2" {
  name        = "dvn-private-ec2-sg"
  description = "Security Group para instancia privada EC2"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "SSH vindo apenas da Instancia Publica"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ec2.id]
  }

  ingress {
    description     = "Trafego de aplicacao vindo da Instancia Publica"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ec2.id]
  }

  egress {
    description = "Saida liberada para o NAT Gateway"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dvn-private-ec2-sg"
  }
}

# Instância EC2 Pública (Subnet Pública 1)
resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.ec2.instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.public_ec2.id]
  associate_public_ip_address = true

  tags = {
    Name = var.ec2.public_instance.name
    Type = "Public"
  }
}

# Instância EC2 Privada (Subnet Privada 1)
resource "aws_instance" "private" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.ec2.instance_type
  subnet_id                   = aws_subnet.private[0].id
  vpc_security_group_ids      = [aws_security_group.private_ec2.id]
  associate_public_ip_address = false

  tags = {
    Name = var.ec2.private_instance.name
    Type = "Private"
  }
}
