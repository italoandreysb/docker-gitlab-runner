# README

## 1. Execute o container do runner

```bash
docker compose -f docker-compose-runner.yml up -d
```

---

## 2. Crie um Instance Runner no GitLab

Acesse o GitLab via navegador e vá em:

```text
Admin Area → CI/CD → Runners → Create instance runner
```

Durante a criação:

- Defina um **Runner description**
- (Opcional) Marque a opção **Run untagged jobs**
- Após finalizar, copie:
  - **Runner URL**
  - **Runner Token**

---

## 3. Registre o runner no container existente

Execute o comando abaixo substituindo os valores da URL e do token:

```bash
docker exec -it gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "https://YOUR-IP-OR-DOMAIN" \
  --token "SEU-TOKEN" \
  --executor "docker" \
  --docker-image "alpine:latest" \
  --description "docker-runner"
```

### Parâmetros importantes

| Parâmetro | Descrição |
|---|---|
| `--url` | URL do GitLab |
| `--token` | Token gerado na criação do runner |
| `--executor docker` | Define o executor Docker |
| `--docker-image` | Imagem padrão utilizada nos jobs |
| `--description` | Nome/descrição do runner |

---

## 4. Verifique se o runner foi registrado

Após o registro, o runner deverá aparecer como **online** na área de runners do GitLab.




