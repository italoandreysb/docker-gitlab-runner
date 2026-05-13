# Guia de configuração

Passo a passo detalhado para configurar e usar o GitLab + GitLab Runner.

## Configuração

1. Crie o arquivo `.env` e ajuste as variáveis:

```bash
touch .env
```

2. Edite `.env` com as portas, hostname e senha desejados:

```ini
GITLAB_HOSTNAME=seu-ip-ou-DNS # ou gitlab.local
GITLAB_EXTERNAL_URL=seu-ip-ou-DNS # ou http://gitlab.local
GITLAB_ROOT_PASSWORD=SuaSenhaForte
GITLAB_HTTP_PORT=80
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

- **URL:** http://localhost:80
- **Usuário:** `root`
- **Senha:** a definida em `GITLAB_ROOT_PASSWORD`

## Registrar o GitLab Runner

Com o GitLab no ar, você precisa de um token de registro para conectar o runner.

### Obtendo o token de registro

Existem dois tipos de token:

- **Token global** (toda a instância) — encontrado em *Admin (ícone de engrenagem, canto inferior esquerdo) > CI/CD > Runners*. Runners registrados com este token ficam disponíveis para todos os projetos.
- **Token de projeto** — encontrado dentro de um projeto específico em *Settings > CI/CD > Runners*. Só aquele projeto pode usar runners registrados com este token. Você precisa criar um projeto primeiro para ver esta opção.

Se não encontrar a opção nos menus, crie um projeto primeiro ou entre como `root` (admin) para acessar as configurações globais.

> **Alternativa:** Você também pode obter o token global diretamente do container:
> ```bash
> docker compose exec gitlab gitlab-rails runner -e production \
>   "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token"
> ```

### Métodos de registro

Você pode registrar o runner de duas formas:

**1. Via CLI (recomendado para Docker):**

```bash
docker compose exec gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "http://gitlab:80" \
  --registration-token "SEU_TOKEN_AQUI" \
  --executor "docker" \
  --docker-image "alpine:latest" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"
```

- `--url http://gitlab:80` — DNS interno do container GitLab (funciona porque estão na mesma rede do compose)
- `--executor docker` — o runner cria containers Docker para executar os jobs
- `--docker-volumes /var/run/docker.sock` — permite que os jobs usem Docker dentro do container (docker-in-docker)

**2. Via Web UI:**

Vá em *Settings > CI/CD > Runners*, clique em "Register a runner" e siga as instruções passo-a-passo (a página mostra o comando de registro já preenchido).

### Verificar o runner

No GitLab, vá em *Admin > CI/CD > Runners* ou *Settings > CI/CD > Runners* do seu projeto. O runner deve aparecer como **online** (verde).

## Como usar

Crie um `.gitlab-ci.yml` na raiz do seu repositório (veja exemplo abaixo). Ao dar push, o GitLab dispara uma pipeline e o runner executa os jobs.

## Exemplo de pipeline

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

Para remover também os volumes (⚠️ apaga todos os dados):

```bash
docker compose down -v
```
