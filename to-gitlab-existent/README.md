# Readme 

1. Execute o runner container

```
docker compose -f docker-compose-runner.yml up -d
```

2. Acesse o gitlab via web e faça a criação em **Admin/runner/create instance runner**
3. Marque a opção "Run untagged jobs" se preferir
4. Defina um runner description
5. Copie a url e o token gerados no processo


## Registrando runnner para container existente
  docker exec -it gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "https://YOUR-IP-OR-DOMAIN" \
  --token "SEU-TOKEN" \
  --executor "docker" \
  --docker-image alpine:latest \
  --description "docker-runner"