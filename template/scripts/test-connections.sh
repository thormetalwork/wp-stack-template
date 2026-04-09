#!/bin/bash
set -euo pipefail

# {{PROJECT_NAME}} — Test Connections
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Testing {{PROJECT_NAME}} Stack ==="

[[ -f "${PROJECT_DIR}/.env" ]] || { echo "ERROR: .env not found at ${PROJECT_DIR}/.env"; exit 1; }
source "${PROJECT_DIR}/.env"

echo -n "MySQL............ "
docker exec {{DOCKER_PREFIX}}_mysql bash -c "MYSQL_PWD='${MYSQL_ROOT_PASSWORD}' mysqladmin ping -u root --silent" 2>/dev/null && echo "OK" || echo "FAIL"

echo -n "Redis............ "
docker exec {{DOCKER_PREFIX}}_redis redis-cli -a "${REDIS_PASSWORD}" --no-auth-warning ping 2>/dev/null || echo "FAIL"

echo -n "WordPress........ "
docker exec {{DOCKER_PREFIX}}_wordpress curl -sf http://localhost/wp-login.php -o /dev/null && echo "OK" || echo "FAIL (may still be starting)"

echo -n "phpMyAdmin....... "
docker exec {{DOCKER_PREFIX}}_phpmyadmin curl -sf http://localhost/ -o /dev/null && echo "OK" || echo "FAIL"

echo ""
docker compose -f "${PROJECT_DIR}/docker-compose.yml" ps
