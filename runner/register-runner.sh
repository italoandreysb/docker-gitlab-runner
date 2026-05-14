#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export $(grep -v '^#' "${SCRIPT_DIR}/.env" | xargs)

echo "======================================="
echo " Registrando GitLab Runner"
echo "======================================="

echo ""
echo "GitLab URL: ${GITLAB_URL}"
echo "Runner Name: ${GITLAB_RUNNER_NAME}"
echo ""

echo "Aguardando GitLab ficar disponível..."

until curl -s "${GITLAB_URL}/-/health" > /dev/null; do
  sleep 5
  echo "GitLab ainda não disponível..."
done

echo ""
echo "GitLab online."
echo ""

docker exec -it gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "${GITLAB_URL}" \
  --token "${GITLAB_RUNNER_TOKEN}" \
  --name "${GITLAB_RUNNER_NAME}" \
  --executor "${GITLAB_RUNNER_EXECUTOR}" \
  --docker-image "${GITLAB_RUNNER_DEFAULT_IMAGE}"

echo ""
echo "Runner registrado com sucesso."