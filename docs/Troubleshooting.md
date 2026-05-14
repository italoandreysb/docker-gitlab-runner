# GitLab Runner Docker Network Troubleshooting

## Problem

GitLab CI pipeline fails during artifact upload.

Pipeline jobs execute correctly, but fail at the end with an error related to artifacts.

---

# Example Error

```text
Uploading artifacts...
public: found 2 matching artifact files and directories

ERROR: Uploading artifacts as "archive" to coordinator...

error=couldn't execute POST against
http://gitlab:80/api/v4/jobs/2/artifacts

dial tcp: lookup gitlab on 192.168.2.155:53:
no such host
```

---

# Root Cause

The GitLab Runner uses the Docker executor.

This means:

```text
GitLab Runner Container
        ↓
Creates temporary job containers
        ↓
Job container executes pipeline
```

The temporary job container was NOT connected to the same Docker network as the GitLab container.

Because of this:

```text
gitlab
```

could not be resolved by Docker DNS.

---

# Verify Existing Networks

Check Docker networks:

```bash
docker network ls
```

Example:

```text
NETWORK ID     NAME
5f21e7a89874   gitlab-docker-cicd_gitlab-network
```

---

# Verify GitLab Runner Configuration

Open the runner container:

```bash
docker exec -it gitlab-runner bash
```

Inspect runner config:

```bash
cat /etc/gitlab-runner/config.toml
```

---

# Problematic Configuration

```toml
[runners.docker]
  image = "python:3.11"
```

No Docker network is defined.

Temporary pipeline containers start in the default Docker bridge network.

---

# Solution

Add `network_mode` to the Docker runner configuration.

Example:

```toml
[runners.docker]
  image = "python:3.11"
  network_mode = "gitlab-docker-cicd_gitlab-network"
```

Use the exact network name from:

```bash
docker network ls
```

---

# Restart GitLab Runner

After editing the config:

```bash
docker restart gitlab-runner
```

---

# Validation

Inside the runner container:

```bash
docker exec -it gitlab-runner bash
```

Test DNS resolution:

```bash
ping gitlab
```

Expected result:

```text
PING gitlab (172.x.x.x)
```

---

# Expected Result

Pipeline should complete successfully:

```text
Uploading artifacts... done
Job succeeded
```

---

# Why This Happens

Docker DNS resolution only works between containers connected to the same Docker network.

Without `network_mode`, the temporary GitLab CI job containers cannot resolve:

```text
gitlab
```

even if the main runner container can.
