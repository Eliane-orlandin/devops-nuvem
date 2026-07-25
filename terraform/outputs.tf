output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ip" {
  description = "IP Público (Elastic IP) do NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "public_instance_id" {
  description = "ID da instância EC2 pública"
  value       = aws_instance.public.id
}

output "public_instance_ip" {
  description = "IP Público da instância EC2 pública"
  value       = aws_instance.public.public_ip
}

output "private_instance_id" {
  description = "ID da instância EC2 privada"
  value       = aws_instance.private.id
}

output "private_instance_ip" {
  description = "IP Privado da instância EC2 privada"
  value       = aws_instance.private.private_ip
}