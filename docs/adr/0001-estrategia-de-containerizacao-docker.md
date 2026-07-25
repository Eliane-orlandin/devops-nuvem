# ADR 0001: Estratégia de Containerização com Docker

## Status
Aprovado
> Aprovado pelo responsável humano.

## Contexto
O projeto necessita de padronização no ambiente de desenvolvimento e execução da aplicação através de containerização. Atualmente, a infraestrutura básica de rede (VPC) já foi provisionada na AWS via Terraform, mas precisamos estabelecer uma estratégia para empacotamento da aplicação e execução de containers de forma reprodutível e isolada.

## Decisão
Adotar a containerização com **Docker**, utilizando uma estrutura padrão baseada em `Dockerfile` multi-stage para otimização de imagens, juntamente com `docker-compose.yml` para orquestração de serviços em ambiente de desenvolvimento local.

## Alternativas consideradas
- **Execução direta na máquina host (Bare-metal / VM sem container)**:
  - *Prós*: Sem overhead de virtualização/containerização.
  - *Contras*: Inconsistência entre ambientes (dev, staging, prod), problemas de dependências locais ("funciona na minha máquina").
- **Docker / Docker Compose**:
  - *Prós*: Padronização completa de ambientes, portabilidade entre clouds e ambiente local, facilidade de integração em pipelines CI/CD e suporte nativo a execução em AWS (ECS/EKS/App Runner).
  - *Contras*: Necessidade de gestão de tamanho de imagens e boas práticas de segurança em imagens base.

## Consequências
- **Positivas**: Ambientes de desenvolvimento e produção idênticos, facilidade no onboarding de desenvolvedores e prontidão para deploy em serviços gerenciados de container na AWS (Amazon ECS / EKS).
- **Negativas / Dívidas técnicas**: Necessidade de manter atualizadas as versões das imagens base e scanner de vulnerabilidades em imagens.

## Plano de implementação (alto nível)
1. **Definição da Aplicação**: Identificar o runtime (Node.js, Python, Go, etc.) ou serviço a ser containerizado.
2. **Criação do Dockerfile**: Estruturar um `Dockerfile` otimizado (uso de imagens leves como Alpine/Distroless, não executar como root, multi-stage build se aplicável).
3. **Criação do docker-compose.yml**: Definir os serviços, redes internas e volumes necessários para desenvolvimento local.
4. **Criação do .dockerignore**: Garantir que arquivos sensíveis, logs e `node_modules` não sejam incluídos no contexto de build.
5. **Validação**: Testar a construção da imagem (`docker build`) e execução do container (`docker run` / `docker compose up`).

## Boas práticas aplicáveis
- **Segurança**: Utilizar usuários não-root (`USER node` ou equivalente), fixar tags de imagens base (evitar `latest`), não incluir secrets ou credenciais no `Dockerfile`.
- **Performance**: Otimizar cache de camadas colocando arquivos de dependências (`package.json`, `requirements.txt`) antes do código-fonte.
- **Tamanho**: Minimizar o tamanho da imagem final usando multi-stage builds.

## Referências
- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [AWS Well-Architected Framework - Operational Excellence](https://docs.aws.amazon.com/wellarchitected/latest/operational-excellence-pillar/welcome.html)

## Log de implementação
- **Data**: 2026-07-25
- **Implementador**: Agente DevOps Engineer
- **Artefatos Criados/Atualizados**:
  - `apps/backend/YoutubeLiveApp/Dockerfile`: Imagem multi-stage baseada em .NET 8 Alpine.
  - `docker-compose.yml`: Arquivo de orquestração local para o serviço backend.

