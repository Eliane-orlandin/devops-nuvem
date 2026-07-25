variable "aws_region" {
  description = "Região AWS padrão para os recursos"
  type        = string
  default     = "us-east-1"
}

variable "vpc" {
  description = "Configuração estruturada da VPC e suas subnets públicas e privadas"
  type = object({
    cidr_block = string
    name       = string
    public_subnets = list(object({
      cidr_block        = string
      availability_zone = string
      name              = string
    }))
    private_subnets = list(object({
      cidr_block        = string
      availability_zone = string
      name              = string
    }))
  })
  default = {
    cidr_block = "10.0.0.0/24"
    name       = "dvn-devops-nuvem-vpc"
    public_subnets = [
      {
        cidr_block        = "10.0.0.0/26"
        availability_zone = "us-east-1a"
        name              = "dvn-public-subnet-1"
      },
      {
        cidr_block        = "10.0.0.64/26"
        availability_zone = "us-east-1b"
        name              = "dvn-public-subnet-2"
      }
    ]
    private_subnets = [
      {
        cidr_block        = "10.0.0.128/26"
        availability_zone = "us-east-1a"
        name              = "dvn-private-subnet-1"
      },
      {
        cidr_block        = "10.0.0.192/26"
        availability_zone = "us-east-1b"
        name              = "dvn-private-subnet-2"
      }
    ]
  }
}