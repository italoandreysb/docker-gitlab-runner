# GitLab + GitLab Runner com Docker Compose

Sobe uma instância do **GitLab CE** e um **GitLab Runner** utilizando Docker Compose, prontos para executar pipelines de CI/CD.

## Pré-requisitos

- Docker Engine 24+
- Docker Compose v2+
- Git (para clonar)

## Estrutura

| Serviço         | Imagem                          | Portas                          |
|-----------------|---------------------------------|---------------------------------|
| gitlab          | gitlab/gitlab-ce:18.0.2-ce.0   | 8080 (HTTP), 8443 (HTTPS), 2222 (SSH) |
| gitlab-runner   | gitlab/gitlab-runner:v18.0.0   | — (executor docker)             |

## Configuração

1. Copie o `.env` e ajuste as variáveis:

```bash
cp .env .env.local
```

2. Edite `.env` com as portas, hostname e senha desejados:

```ini
GITLAB_HOSTNAME=gitlab.local
GITLAB_EXTERNAL_URL=http://gitlab.local
GITLAB_ROOT_PASSWORD=SuaSenhaForte
GITLAB_HTTP_PORT=8080
GITLAB_HTTPS_PORT=8443
GITLAB_SSH_PORT=2222
```

> ⚠️ Altere `GITLAB_ROOT_PASSWORD` para uma senha forte.

## Subir os serviços

```bash
docker compose up -d
```

Aguarde alguns minutos até o GitLab iniciar completamente. Acompanhe os logs:

```bash
docker compose logs -f gitlab
```

## Acessar o GitLab

- **URL:** http://localhost:8080
- **Usuário:** `root`
- **Senha:** a definida em `GITLAB_ROOT_PASSWORD`

## Registrar o GitLab Runner

Com o GitLab no ar, registre o runner para um projeto ou globalmente.

1. Obtenha o **token** de registro em: *Settings > CI/CD > Runners* no projeto ou na administração.

2. Execute o registro:

```bash
docker compose exec gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "http://gitlab:80" \
  --token "SEU_TOKEN_AQUI" \
  --executor "docker" \
  --docker-image "alpine:latest" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"
```

> O DNS interno `http://gitlab:80` funciona porque o runner está na mesma rede do compose.
> O volume `/var/run/docker.sock` permite que o runner execute containers Docker (docker-in-docker / docker executor).

## Verificar o runner

No GitLab, vá em *Settings > CI/CD > Runners* e confirme que o runner aparece como **online**.

## Exemplo de pipeline

Crie um `.gitlab-ci.yml` na raiz do seu repositório:

```yaml
stages:
  - test
  - build

test-job:
  stage: test
  script:
    - echo "Rodando testes..."

build-job:
  stage: build
  script:
    - echo "Fazendo build..."
```

## Volumes persistentes

Os dados são mantidos em volumes Docker:

- `gitlab_config` — configurações do GitLab
- `gitlab_logs` — logs
- `gitlab_data` — dados (repositórios, banco, etc.)
- `gitlab_runner_config` — configuração do runner (`config.toml`)

## Parar e remover

```bash
docker compose down
```

Para remover também os volumes (apaga todos os dados):

```bash
docker compose down -v
```
