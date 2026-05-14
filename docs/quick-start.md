# GitLab Docker CI/CD

Spin up a GitLab instance with a Docker-based runner using Docker Compose.

## Prerequisites

- Docker and Docker Compose
- `chmod +x` permission on the register script

## Quick Start

### 1. Configure environment variables

```bash
cp gitlab/.env_model gitlab/.env
cp runner/.env_model runner/.env
```

Edit both `.env` files with your settings.

**`gitlab/.env`** — GitLab hostname, URL, and root password:

| Variable | Description |
|---|---|
| `GITLAB_HOSTNAME` | Container hostname (e.g., `10.132.3.94`) |
| `GITLAB_EXTERNAL_URL` | Public URL (e.g., `http://10.132.3.94`) |
| `GITLAB_ROOT_PASSWORD` | Initial password for the `root` user |
| `GITLAB_HTTP_PORT` | HTTP port (default `80`) |
| `GITLAB_HTTPS_PORT` | HTTPS port (default `8443`) |
| `GITLAB_SSH_PORT` | SSH port (default `2222`) |

**`runner/.env`** — Runner registration (filled in step 4):

| Variable | Description |
|---|---|
| `GITLAB_URL` | GitLab instance URL |
| `GITLAB_RUNNER_TOKEN` | Registration token from GitLab UI |
| `GITLAB_RUNNER_NAME` | Runner name |
| `GITLAB_RUNNER_EXECUTOR` | Executor (e.g., `docker`) |
| `GITLAB_RUNNER_DEFAULT_IMAGE` | Default Docker image (e.g., `python:3.11`) |

### 2. Start GitLab

```bash
docker compose -f gitlab/docker-compose-gitlab.yml up -d
```

Wait a few minutes for GitLab to fully initialize.

### 3. Start the Runner

```bash
docker compose -f runner/docker-compose-runner.yml up -d
```

### 4. Register the Runner

1. Open your GitLab instance in a browser.
2. Go to **Admin → CI/CD → Runners**.
3. Copy the instance URL and registration token.
4. Fill them into `runner/.env` (see table above).
5. Run the registration script:

```bash
chmod +x runner/register-runner.sh
cd runner && ./register-runner.sh
```

The script waits for GitLab to become available and then registers the runner automatically.

## Troubleshooting

See [docs/Troubleshooting.md](docs/Troubleshooting.md) for common issues such as artifact upload failures due to Docker networking.
