# GitLab + GitLab Runner com Docker Compose

Sobe uma instância do **GitLab CE** e um **GitLab Runner** utilizando Docker Compose, prontos para executar pipelines de CI/CD.

## Pré-requisitos

- Docker Engine 24+
- Docker Compose v2+
- Git (para clonar)

## Estrutura

| Serviço        | Imagem                           | Portas                              |
|----------------|----------------------------------|-------------------------------------|
| gitlab         | gitlab/gitlab-ce:18.0.2-ce.0    | 80 (HTTP), 8443 (HTTPS), 2222 (SSH) |
| gitlab-runner  | gitlab/gitlab-runner:v18.0.0    | — (docker executor)                 |

## Quick start

```bash
cp .env.example .env    # configure as variáveis
docker compose up -d    # sobe GitLab e Runner
```

Guia completo de configuração → [`docs/setup-pt-br.md`](docs/setup-pt-br.md) (PT-BR) / [`docs/setup.md`](docs/setup.md) (EN)

Inclui: configuração do `.env`, registro do runner, exemplo de pipeline, volumes persistentes e como parar/remover.

## Boas práticas DevOps

| Prática | Como é aplicada |
|---|---|
| **Infraestrutura como Código** | Ambiente inteiro definido no `docker-compose.yml` — reproduzível com um comando |
| **Separação de responsabilidades** | Configuração isolada no `.env`, segredos no `.gitignore`, lógica no `docker-compose.yml` |
| **Infraestrutura imutável** | Versões fixas nas imagens em vez de `latest` |
| **Persistência com volumes** | Volumes nomeados preservam dados entre reinícios |
| **Isolamento de serviços** | GitLab e Runner em containers separados com responsabilidades distintas |
| **Docker-in-Docker (DinD)** | Runner monta `/var/run/docker.sock` para jobs criarem containers |
| **Gerenciamento de saúde** | `restart: unless-stopped` garante recuperação automática de falhas |
| **Fonte única de verdade** | Parâmetros configuráveis centralizados no `.env` |
| **Segurança** | `shm_size: 256m` previne problemas de memória compartilhada; SSH em porta não padrão |

## Próximos passos

- **Registro automatizado do runner** — script que registra o runner automaticamente via API do GitLab
- **Pipeline real** — um `.gitlab-ci.yml` que builda uma app, roda testes, gera imagem Docker e faz push ao registry
- **TLS/HTTPS** — configure certificados Let's Encrypt ou auto-assinados
- **Terraform provider** — gerencie recursos do GitLab como código
- **Monitoramento** — adicione Prometheus + Grafana para métricas do GitLab
- **Estratégia de backup** — script para exportar e restaurar volumes Docker
