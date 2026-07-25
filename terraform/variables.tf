variable "aws_region" {
  type        = string
  description = "Região AWS"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block principal da VPC"
  default     = "10.0.0.0/24"
}

variable "public_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
    name              = string
  }))
  description = "Lista de subnets públicas"
  default = [
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
}

variable "private_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
    name              = string
  }))
  description = "Lista de subnets privadas"
  default = [
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