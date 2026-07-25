# ADR 0004: Armazenamento Remoto do Terraform State (Remote Backend S3 e State Locking DynamoDB)

## Status
Proposto
> Aprovação manual obrigatória por um humano antes da implementação.

## Contexto
Atualmente, o arquivo de estado do Terraform (`terraform.tfstate`) está sendo mantido localmente. Em um ambiente colaborativo e de produção, guardar o estado localmente traz riscos de perda de dados, conflitos de concorrência e falta de rastreabilidade de alterações na infraestrutura.

## Decisão
Implementar um **Remote Backend na AWS** composto por um **Bucket S3** com versionamento ativado e uma tabela **DynamoDB** para bloqueio de estado (*State Locking*), organizados em uma nova stack independente denominada `00-remote-backend-stack`.

### Componentes da Solução:
1. **Stack Dedicada (`00-remote-backend-stack`)**:
   - Estruturada no diretório `terraform/stacks/00-remote-backend-stack/`.
   - Isolada da infraestrutura principal para permitir que o backend seja criado primeiro com estado local e, em seguida, sirva de suporte remoto para as demais stacks.

2. **Bucket S3 (`aws_s3_bucket`)**:
   - **Versionamento**: Habilitado via `aws_s3_bucket_versioning` para permitir recuperação de estados anteriores em caso de falha.
   - **Criptografia**: Criptografia em repouso AES256 por padrão (`aws_s3_bucket_server_side_encryption_configuration`).
   - **Segurança**: Bloqueio total de acesso público (`aws_s3_bucket_public_access_block`).
   - **Proteção contra exclusão acidental**: `lifecycle { prevent_destroy = true }`.

3. **Tabela DynamoDB (`aws_dynamodb_table`)**:
   - Utilizada para trava de concorrência (*State Locking*).
   - Atributo de chave primária: `LockID` (tipo `S` / String).
   - Modo de cobrança: `PAY_PER_REQUEST` (On-Demand).

4. **Migração Futura**:
   - Após o provisionamento da stack `00-remote-backend-stack`, as demais stacks (como a stack de rede e EC2) passarão a configurar o bloco `backend "s3"` apontando para o bucket e tabela DynamoDB criados.

## Alternativas consideradas
- **Manter estado local (`terraform.tfstate`)**:
  - *Prós*: Simplicidade inicial sem dependência de recursos na AWS.
  - *Contras*: Alto risco de sobrescrita acidental, falta de trava de execução concorrente e impossibilidade de trabalho em equipe via CI/CD.
- **Usar Terraform Cloud**:
  - *Prós*: Solução gerenciada completa.
  - *Contras*: Vendor lock-in de plataforma SaaS externa e custos associados a limites de usuários/recursos.

## Consequências
- **Positivas**: Segurança do estado da infraestrutura, versionamento histórico de alterações, prevenção contra execuções simultâneas e suporte a pipelines CI/CD automatizadas.
- **Negativas / Riscos**: Custo residual irrisório pelo armazenamento S3 e leituras/escritas no DynamoDB (cobertos pelo Free Tier).

## Plano de implementação (alto nível)
1. **Estrutura de Diretórios**: Criar o diretório `terraform/stacks/00-remote-backend-stack/`.
2. **Variáveis**: Criar `variables.tf` na nova stack com objeto estruturado `var.remote_backend` contendo os nomes do bucket, tabela e ambiente.
3. **Recursos S3**: Criar `s3.tf` declarando o bucket S3, recurso de versionamento, criptografia e bloqueio de acesso público.
4. **Recursos DynamoDB**: Criar `dynamodb.tf` para a tabela de lock.
5. **Providers & Outputs**: Criar `providers.tf` e `outputs.tf` expondo o nome do bucket, ARN e nome da tabela DynamoDB.
6. **Validação & Aplicação Inicial**: Executar `terraform init`, `terraform validate` e `terraform plan` dentro da nova stack.

## Boas práticas aplicáveis
- **Regras de Nomenclatura**: Nomes no singular (`aws_s3_bucket.this`, `aws_dynamodb_table.this`), uso de `_` nos identificadores e hífen nos nomes dos recursos AWS.
- **Sem Hardcode**: Parametrizar prefixos e nomes do bucket via variável `var.remote_backend`.
- **Layout Modular**: Arquivos separados por responsabilidade (`s3.tf`, `dynamodb.tf`, `providers.tf`, `variables.tf`, `outputs.tf`).

## Referências
- [Terraform Backend S3 Specification](https://developer.hashicorp.com/terraform/language/backend/s3)
- [AWS S3 Bucket Versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)
