#!/usr/bin/env bash
# Запуск стека на VPS (после docker load и настройки .env.production)
set -euo pipefail

cd "$(dirname "$0")/../.."

if [[ ! -f .env.production ]]; then
  echo "Создайте .env.production из .env.production.example"
  exit 1
fi

if ! docker image inspect taskflow-backend:latest &>/dev/null; then
  echo "Образ taskflow-backend:latest не найден. Выполните: docker load -i taskflow-backend.tar"
  exit 1
fi

docker compose -f docker-compose.prod.yml --env-file .env.production up -d

echo ""
echo "Проверка:"
sleep 3
curl -sf "http://localhost:${PORT:-3100}/health/live" && echo " — live OK" || echo " — live FAILED"
curl -sf "http://localhost:${PORT:-3100}/health/ready" && echo " — ready OK" || echo " — ready FAILED (подождите миграции)"
