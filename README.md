# GitLab + GitLab Runner with Docker Compose

Spins up a **GitLab CE** instance and a **GitLab Runner** using Docker Compose, ready to run CI/CD pipelines.

## Prerequisites

- Docker Engine 24+
- Docker Compose v2+
- Git (to clone)

## Structure

| Service        | Image                           | Ports                              |
|----------------|---------------------------------|------------------------------------|
| gitlab         | gitlab/gitlab-ce:18.0.2-ce.0   | 80 (HTTP), 8443 (HTTPS), 2222 (SSH) |
| gitlab-runner  | gitlab/gitlab-runner:v18.0.0   | — (docker executor)                |

## DevOps best practices

This project follows key infrastructure and Docker Compose best practices:

| Practice | How it's applied |
|---|---|
| **Infrastructure as Code** | Entire environment defined in `docker-compose.yml` — reproducible with a single command |
| **Separation of concerns** | Configuration isolated in `.env`, secrets in `.gitignore`d `.env`, logic in `docker-compose.yml` |
| **Immutable infrastructure** | Services use pinned version tags (`18.0.2-ce.0`, `v18.0.0`) instead of `latest` |
| **Persistence via volumes** | Named Docker volumes (`gitlab_config`, `gitlab_data`, `gitlab_logs`, `gitlab_runner_config`) keep data across restarts |
| **Service isolation** | GitLab and Runner run in separate containers with distinct responsibilities |
| **Docker-in-Docker (DinD)** | Runner mounts `/var/run/docker.sock` so pipeline jobs can spawn containers without nested Docker |
| **Health management** | `restart: unless-stopped` ensures services recover from failures automatically |
| **Ephemeral runner config** | Runner configuration is stored in a volume; can be destroyed and re-registered without affecting GitLab data |
| **Single source of truth** | All configurable parameters (ports, passwords, hostname) centralized in `.env` |
| **Security** | `shm_size: 256m` prevents shared memory issues; SSH on non-standard port; initial root password set via environment |


## Configuration

1. Copy `.env` and adjust the variables:

```bash
touch .env
```

2. Edit `.env` with your desired ports, hostname and password:

```ini
GITLAB_HOSTNAME=your-ip-or-DNS # or gitlab.local 
GITLAB_EXTERNAL_URL=your-ip-or-DNS # or http://gitlab.local
GITLAB_ROOT_PASSWORD=YourStrongPassword
GITLAB_HTTP_PORT=80
GITLAB_HTTPS_PORT=8443
GITLAB_SSH_PORT=2222
```

> ⚠️ Change `GITLAB_ROOT_PASSWORD` to a strong password.

## Start the services

```bash
docker compose up -d
```

Wait a few minutes for GitLab to fully start. Follow the logs:

```bash
docker compose logs -f gitlab
```

## Access GitLab

- **URL:** http://localhost:80
- **User:** `root`
- **Password:** the one set in `GITLAB_ROOT_PASSWORD`

## Register the GitLab Runner

Once GitLab is up, you need a registration token to connect the runner to GitLab.

### Getting the registration token

There are two types of tokens:

- **Global token** (instance-wide) — found at *Admin Area (gear icon, bottom-left) > CI/CD > Runners*. Runners registered with this token are available to all projects.
- **Project token** — found inside a specific project at *Settings > CI/CD > Runners*. Only that project can use runners registered with this token. You must create a project first to see this option.

If you can't find the option in the menus, create a project first or log in as `root` (admin) to access the global settings.

> **Alternative:** You can also retrieve the global token directly from the container:
> ```bash
> docker compose exec gitlab gitlab-rails runner -e production \
>   "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token"
> ```

### Registration methods

You can register the runner in two ways:

**1. Via CLI (recommended for Docker):**

```bash
docker compose exec gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "http://gitlab:80" \
  --registration-token "YOUR_TOKEN_HERE" \
  --executor "docker" \
  --docker-image "alpine:latest" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"
```

- `--url http://localhost:80` — internal DNS of the GitLab container (works because they share the same compose network)
- `--executor docker` — the runner creates Docker containers to execute jobs
- `--docker-volumes /var/run/docker.sock` — allows jobs to use Docker inside the container (docker-in-docker)

**2. Via Web UI:**

Go to *Settings > CI/CD > Runners*, click "Register a runner", and follow the step-by-step instructions (the page shows the register command already filled in).

### Verify the runner

In GitLab, go to *Admin > CI/CD > Runners* or *Settings > CI/CD > Runners* of your project. The runner should appear as **online** (green).

## How to use

Create a `.gitlab-ci.yml` at the root of your repository (see example below). When you push, GitLab triggers a pipeline, and the runner executes the jobs.

## Pipeline example

Create a `.gitlab-ci.yml` at the root of your repository:

```yaml
stages:
  - test
  - build

test-job:
  stage: test
  script:
    - echo "Running tests..."

build-job:
  stage: build
  script:
    - echo "Building..."
```

## Persistent volumes

Data is kept in Docker volumes:

- `gitlab_config` — GitLab configuration
- `gitlab_logs` — logs
- `gitlab_data` — data (repositories, database, etc.)
- `gitlab_runner_config` — runner configuration (`config.toml`)


## Stop and remove

```bash
docker compose down
```

To also remove the volumes (⚠️ deletes all data):

```bash
docker compose down -v
```
