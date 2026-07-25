# ADR 0003: Instâncias EC2 Pública (Bastion/Web) e Privada (Application)

## Status
Aprovado
> Aprovado pelo responsável humano.

## Contexto
Após o provisionamento da topologia de rede na AWS (VPC `10.0.0.0/24` com subnets públicas e privadas), o ambiente precisa de capacidade computacional (servidores EC2) para hospedar os serviços da aplicação e permitir acesso seguro de administração.

## Decisão
Implementar duas instâncias EC2 utilizando Amazon Linux 2023 com segregação de acesso baseada na camada de rede:

### 1. Instância EC2 Pública (Bastion Host / Web Server)
- **Localização**: `Subnet Pública 1` (`10.0.0.0/26`).
- **Endereçamento**: IP público associado automaticamente (`map_public_ip_on_launch = true`).
- **Security Group (`dvn-public-ec2-sg`)**:
  - Ingress: Porta `80` (HTTP) e `443` (HTTPS) liberadas para `0.0.0.0/0`.
  - Ingress: Porta `22` (SSH) liberada para administração.
  - Egress: Liberado para `0.0.0.0/0`.

### 2. Instância EC2 Privada (Application / Backend Server)
- **Localização**: `Subnet Privada 1` (`10.0.0.128/26`).
- **Endereçamento**: Apenas IP privado interno (sem IP público). Tráfego de saída à internet roteado via NAT Gateway.
- **Security Group (`dvn-private-ec2-sg`)**:
  - Ingress: Porta `22` (SSH) e portas de aplicação (ex: `8080`) permitidas **apenas a partir do Security Group da instância pública** (`dvn-public-ec2-sg`).
  - Egress: Liberado para `0.0.0.0/0` (via NAT Gateway).

### 3. Especificações Técnicas das Instâncias
- **AMI**: Busca dinâmica da imagem mais recente do **Amazon Linux 2023** via Data Source (`aws_ami.amazon_linux_2023`).
- **Instance Type**: `t3.micro` (elegível para Free Tier da AWS, parametrizado via objeto de variáveis).

## Alternativas consideradas
- **Todas as instâncias em Subnets Públicas**:
  - *Prós*: Acesso direto simplificado.
  - *Contras*: Alto risco de segurança, exposição desnecessária do backend e banco de dados a ataques externos.
- **Uso de AWS Systems Manager (SSM) Session Manager em vez de SSH aberto**:
  - *Prós*: Elimina necessidade de abrir porta 22 e gerenciar chaves SSH.
  - *Contras*: Requer IAM Role com permissões do SSM anexadas à instância.
  - *Decisão*: Manter suporte inicial a Security Groups restritos e preparar IAM Role para SSM.

## Consequências
- **Positivas**: Arquitetura em camadas (Defense in Depth) impedindo acesso direto da internet aos servidores privados; administração segura via Bastion.
- **Negativas / Riscos**: Acesso SSH ao servidor privado exige um "pulo" (*jump host*) pela instância pública.

## Plano de implementação (alto nível)
1. **Data Sources**: Adicionar busca dinâmica da AMI Amazon Linux 2023.
2. **Security Groups**: Criar Security Groups dedicados para a camada pública e privada com regras de tráfego encadeadas.
3. **Variáveis**: Estender o objeto de variáveis em `variables.tf` para incluir a configuração das instâncias (`ec2`).
4. **Recursos de Compute**: Criar arquivo `ec2.tf` declarando a instância pública e a instância privada.
5. **Outputs**: Adicionar em `outputs.tf` o IP público da instância pública e o IP privado da instância privada.
6. **Validação**: Executar `terraform validate` e `terraform plan`.

## Boas práticas aplicáveis
- **Regras de Nomenclatura**: Nomes no singular com `_` (`aws_instance.public`, `aws_instance.private`), sem repetição do tipo do recurso.
- **Sem Hardcode**: Especificação da AMI via Data Source e parametrização do `instance_type` via variável `var.ec2`.
- **Menor Privilégio**: Security Group privado autorizando entrada apenas vinda do SG público.

## Referências
- [AWS EC2 Security Groups Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/working-with-security-groups.html)
- [Terraform aws_instance Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

## Log de implementação
- **Data**: 2026-07-25
- **Implementador**: Agente DevOps Engineer
- **Artefatos Criados/Atualizados**:
  - `terraform/variables.tf`: Adicionada variável de objeto estruturada `var.ec2`.
  - `terraform/ec2.tf`: Criado arquivo com data source `aws_ami.amazon_linux_2023`, Security Groups (`aws_security_group.public_ec2`, `aws_security_group.private_ec2`) e instâncias EC2 (`aws_instance.public`, `aws_instance.private`).
  - `terraform/outputs.tf`: Adicionados outputs `public_instance_id`, `public_instance_ip`, `private_instance_id` e `private_instance_ip`.
- **Validação**: `terraform validate` executado com sucesso; `terraform plan` gerou o plano com 4 novos recursos a adicionar.

