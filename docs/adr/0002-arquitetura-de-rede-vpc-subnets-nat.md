# ADR 0002: Arquitetura de Rede VPC com 4 Subnets e NAT Gateway Único

## Status
Aprovado
> Aprovado pelo responsável humano.

## Contexto
A infraestrutura precisa de uma topologia de rede segura e segregada na AWS para abrigar workloads públicos (ex: Load Balancers, Ingress Controllers) e privados (ex: containers de aplicação, bancos de dados). O endereçamento IP precisa ser otimizado utilizando a faixa `10.0.0.0/24`, dividida em 4 sub-redes (`/26`) distribuídas em 2 zonas de disponibilidade (AZs) para resiliência básica, otimizando os custos com a implantação de um único NAT Gateway.

## Decisão
Implementar uma Virtual Private Cloud (VPC) na AWS com a seguinte estrutura de sub-redes e roteamento:

### 1. Endereçamento e Divisão de Subnets (`10.0.0.0/24`)
- **VPC CIDR**: `10.0.0.0/24` (256 endereços IP)
- **Subnet Pública 1**: `10.0.0.0/26` (64 IPs, AZ 1 - ex: `us-east-1a`)
- **Subnet Pública 2**: `10.0.0.64/26` (64 IPs, AZ 2 - ex: `us-east-1b`)
- **Subnet Privada 1**: `10.0.0.128/26` (64 IPs, AZ 1 - ex: `us-east-1a`)
- **Subnet Privada 2**: `10.0.0.192/26` (64 IPs, AZ 2 - ex: `us-east-1b`)

### 2. Componentes de Roteamento e Conectividade
- **Internet Gateway (IGW)**: Vinculado à VPC para fornecer conectividade direta de/para a internet pública.
- **NAT Gateway Único**: Alocado na **Subnet Pública 1** (`10.0.0.0/26`) com um Elastic IP (EIP) associado.
- **Public Route Table**: Rota `0.0.0.0/0` direcionando para o Internet Gateway (associada às Subnets Públicas 1 e 2).
- **Private Route Table**: Rota `0.0.0.0/0` direcionando para o NAT Gateway Único (associada às Subnets Privadas 1 e 2).

## Alternativas consideradas
- **NAT Gateway por Zona de Disponibilidade (Multi-AZ NAT Gateway)**:
  - *Prós*: Alta disponibilidade em caso de falha da AZ onde o NAT Gateway está hospedado.
  - *Contras*: Custo mensal duplicado por conta das instâncias de NAT Gateway ociosas em ambientes não-críticos.
  - *Razão do descarte*: Para ambientes de desenvolvimento/workshop, 1 NAT Gateway atende a necessidade de saída à internet reduzindo custos operacionais.
- **Uso de NAT Instance (EC2)**:
  - *Prós*: Custo potencialmente menor.
  - *Contras*: Necessidade de gerenciamento de patches, escalabilidade manual e sem garantia de alta disponibilidade gerenciada pela AWS.

## Consequências
- **Positivas**: Isolamento de segurança rigoroso (recursos privados sem IP público diretamente exposto), economia de custos com NAT Gateway único, infraestrutura preparada para alta disponibilidade em 2 AZs.
- **Negativas / Riscos**: Se a AZ 1 (onde está o NAT Gateway) sofrer uma interrupção total, as instâncias da Subnet Privada 2 perderão acesso temporário de saída à internet.

## Plano de implementação (alto nível)
1. **Configuração da VPC e IGW**: Declarar a VPC `10.0.0.0/24` e o Internet Gateway no arquivo Terraform.
2. **Declaração das Subnets**: Criar as 2 subnets públicas (`10.0.0.0/26` e `10.0.0.64/26`) e as 2 subnets privadas (`10.0.0.128/26` e `10.0.0.192/26`) com suas respectivas AZs.
3. **Provisionamento do EIP e NAT Gateway**: Criar um `aws_eip` e o `aws_nat_gateway` associado à Subnet Pública 1.
4. **Tabelas de Roteamento e Associações**:
   - Criar `aws_route_table` pública (com rota `0.0.0.0/0` -> IGW) e associar às subnets públicas.
   - Criar `aws_route_table` privada (com rota `0.0.0.0/0` -> NAT Gateway) e associar às subnets privadas.
5. **Validação**: Executar `terraform validate` e `terraform plan` para conferir a criação dos 11 recursos de rede.

## Boas práticas aplicáveis
- **Segurança**: Habilitar `map_public_ip_on_launch = true` apenas nas subnets públicas; manter `map_public_ip_on_launch = false` nas subnets privadas.
- **Gestão de Custos**: Alocação de 1 único NAT Gateway conforme requisito.
- **Marcação (Tagging)**: Aplicar tags padronizadas (`Name`, `Environment`, `Project`) em todos os recursos de rede.

## Referências
- [AWS VPC Subnet CIDR Block Calculation](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html)
- [AWS Single NAT Gateway Architecture](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)

## Log de implementação
- **Data**: 2026-07-25
- **Implementador**: Agente DevOps Engineer
- **Artefatos Criados/Atualizados**:
  - `terraform/variables.tf`: Variáveis para VPC (`10.0.0.0/24`), 2 subnets públicas (`/26`) e 2 subnets privadas (`/26`).
  - `terraform/main.tf`: Declaração dos recursos de rede (`aws_vpc`, `aws_internet_gateway`, `aws_subnet.public`, `aws_subnet.private`, `aws_eip`, `aws_nat_gateway`, `aws_route_table`, `aws_route_table_association`).
  - `terraform/outputs.tf`: Outputs de `vpc_id`, `public_subnet_ids`, `private_subnet_ids` e `nat_gateway_ip`.
- **Validação**: `terraform validate` executado com sucesso; `terraform plan` gerou o plano com 14 recursos a adicionar.

