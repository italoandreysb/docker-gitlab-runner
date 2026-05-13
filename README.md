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

## Quick start

```bash
cp .env.example .env    # configure your variables
docker compose up -d    # start GitLab and Runner
```

Full setup guide → [`docs/setup.md`](docs/setup.md) (EN) / [`docs/setup-pt-br.md`](docs/setup-pt-br.md) (PT-BR)

Includes: configuring `.env`, registering the runner, pipeline example, persistent volumes, and how to stop/remove.

## DevOps best practices

| Practice | How it's applied |
|---|---|
| **Infrastructure as Code** | Entire environment defined in `docker-compose.yml` — reproducible with a single command |
| **Separation of concerns** | Configuration isolated in `.env`, secrets in `.gitignore`d `.env`, logic in `docker-compose.yml` |
| **Immutable infrastructure** | Services use pinned version tags (`18.0.2-ce.0`, `v18.0.0`) instead of `latest` |
| **Persistence via volumes** | Named Docker volumes keep data across restarts |
| **Service isolation** | GitLab and Runner run in separate containers with distinct responsibilities |
| **Docker-in-Docker (DinD)** | Runner mounts `/var/run/docker.sock` so pipeline jobs can spawn containers |
| **Health management** | `restart: unless-stopped` ensures services recover from failures automatically |
| **Single source of truth** | All configurable parameters centralized in `.env` |
| **Security** | `shm_size: 256m` prevents shared memory issues; SSH on non-standard port |

## To do

- **Automated runner registration** — a shell script that registers the runner automatically via the GitLab API
- **Real pipeline** — a `.gitlab-ci.yml` that builds an app, runs tests, creates a Docker image, and pushes to the registry
- **TLS/HTTPS** — configure Let's Encrypt or self-signed certificates
- **Terraform provider** — manage GitLab resources as code
- **Monitoring** — add Prometheus + Grafana for GitLab metrics
- **Backup strategy** — script to dump and restore Docker volumes
