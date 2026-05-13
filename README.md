# GitLab + GitLab Runner with Docker Compose

Spins up a **GitLab CE** instance and a **GitLab Runner** using Docker Compose, ready to run CI/CD pipelines.

## Prerequisites

- Docker Engine 24+
- Docker Compose v2+
- Git (to clone)

## Structure

| Service        | Image                           | Ports                              |
|----------------|---------------------------------|------------------------------------|
| gitlab         | gitlab/gitlab-ce:18.0.2-ce.0   | 8080 (HTTP), 8443 (HTTPS), 2222 (SSH) |
| gitlab-runner  | gitlab/gitlab-runner:v18.0.0   | — (docker executor)                |

## Configuration

1. Copy `.env` and adjust the variables:

```bash
touch .env
```

2. Edit `.env` with your desired ports, hostname and password:

```ini
GITLAB_HOSTNAME=gitlab.local
GITLAB_EXTERNAL_URL=http://gitlab.local
GITLAB_ROOT_PASSWORD=YourStrongPassword
GITLAB_HTTP_PORT=8080
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

- **URL:** http://localhost:8080
- **User:** `root`
- **Password:** the one set in `GITLAB_ROOT_PASSWORD`

## Register the GitLab Runner

Once GitLab is up, register the runner for a project or globally.

1. Get the registration **token** from *Settings > CI/CD > Runners* in your project or admin area.

2. Run the registration:

```bash
docker compose exec gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "http://gitlab:80" \
  --token "YOUR_TOKEN_HERE" \
  --executor "docker" \
  --docker-image "alpine:latest" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"
```

> The internal DNS `http://gitlab:80` works because the runner is on the same compose network.
> The `/var/run/docker.sock` volume allows the runner to spawn Docker containers (docker-in-docker / docker executor).

## Verify the runner

In GitLab, go to *Settings > CI/CD > Runners* and confirm the runner shows as **online**.

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
