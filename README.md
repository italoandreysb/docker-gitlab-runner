# Principais Pontos Técnicos da Arquitetura

## Separação entre GitLab e Runner

A infraestrutura foi dividida em dois ambientes independentes:

- GitLab (plataforma principal)
- GitLab Runner (execução de pipelines)

Essa separação reduz acoplamento entre serviços e segue boas práticas utilizadas em ambientes CI/CD modernos.

---

## Desacoplamento Operacional

O GitLab e os Runners possuem ciclos de vida diferentes:

### GitLab
Responsável por:
- Interface Web
- Repositórios Git
- API
- Registry
- Autenticação
- Banco de dados interno

### Runner
Responsável por:
- Build
- Testes
- Deploy
- Execução das pipelines

Com isso:
- atualizações tornam-se independentes
- reinicializações afetam apenas um componente
- manutenção fica mais simples

---

## Escalabilidade Horizontal

A estrutura permite adicionar múltiplos runners futuramente sem alterar o ambiente principal.

Exemplo:
- runner-docker
- runner-shell
- runner-gpu
- runner-arm

Isso facilita crescimento da plataforma CI/CD conforme a demanda aumenta.

---

## Persistência de Dados

Os dados críticos do GitLab utilizam volumes persistentes:

- `/etc/gitlab`
- `/var/log/gitlab`
- `/var/opt/gitlab`

Garantindo:
- persistência após reinicialização
- maior segurança operacional
- facilidade para backup e restore

---

## Automação do Registro do Runner

O processo de autenticação do runner foi automatizado via script shell utilizando variáveis externas em `.env`.

Benefícios:
- padronização
- reprodutibilidade
- redução de erros manuais
- provisionamento simplificado

---

## Configuração Externalizada via `.env`

As variáveis sensíveis e de ambiente foram desacopladas dos arquivos Compose.

Exemplos:
- URL do GitLab
- Tokens
- Senhas
- Portas
- Hostname

Isso melhora:
- segurança
- portabilidade
- versionamento
- reutilização da infraestrutura

---

## Isolamento de Rede

Cada compose utiliza rede bridge dedicada.

Isso:
- melhora organização
- reduz acoplamento entre containers
- facilita troubleshooting
- aumenta previsibilidade da comunicação

---

## Uso de Docker Executor

O Runner utiliza Docker Executor através do compartilhamento do socket Docker:

`/var/run/docker.sock`

Permitindo:
- builds rápidos
- execução de containers nas pipelines
- menor overhead comparado ao Docker-in-Docker

---

## Arquitetura Preparada para Expansão

A estrutura atual permite futura integração com:
- Reverse Proxy
- HTTPS/TLS
- DNS interno
- Monitoramento
- Backup automatizado
- Kubernetes
- Runners distribuídos

Sem necessidade de refatoração significativa.

---

## Organização da Infraestrutura

Estrutura recomendada:

```text
infra/
├── gitlab/
│   ├── docker-compose.gitlab.yml
│   └── .env
│
├── runner/
│   ├── docker-compose.runner.yml
│   ├── register-runner.sh
│   └── .env
```

Essa organização melhora:
- manutenção
- automação
- legibilidade
- versionamento
- CI da própria infraestrutura

---

## Compatibilidade com GitLab 18+

A solução foi adaptada para o novo fluxo de autenticação de runners introduzido nas versões recentes do GitLab, utilizando:
- Authentication Tokens (`glrt-*`)
- Registro não interativo
- Configuração centralizada no servidor GitLab

Garantindo compatibilidade com versões atuais e futuras da plataforma.
