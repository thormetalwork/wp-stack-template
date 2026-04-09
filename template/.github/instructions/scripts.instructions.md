---
description: "Use when writing or editing shell scripts: backup, restore, deployment, testing, cache management."
applyTo: "scripts/**"
---
# Shell Script Guidelines — {{PROJECT_NAME}}

## Required Patterns
- Always start with `#!/bin/bash` and `set -e`
- Quote all variables: `"${VAR}"` not `$VAR`
- Validate `.env` exists before sourcing: `[[ -f .env ]] || { echo "Missing .env"; exit 1; }`
- Use `docker compose` (v2 syntax, not `docker-compose`)

## Docker Commands
- Container names: `{{DOCKER_PREFIX}}_mysql`, `{{DOCKER_PREFIX}}_redis`, `{{DOCKER_PREFIX}}_wordpress`, `{{DOCKER_PREFIX}}_phpmyadmin`
- MySQL exec: `docker exec {{DOCKER_PREFIX}}_mysql bash -c "MYSQL_PWD='...' mysqladmin -u root ping"`
- Redis exec: `docker exec {{DOCKER_PREFIX}}_redis redis-cli -a "$REDIS_PASSWORD" --no-auth-warning ping`
- WordPress check: `docker exec {{DOCKER_PREFIX}}_wordpress curl -sf http://localhost/wp-login.php`

## Backup Convention
- Filename: `{database}_YYYYMMDD_HHMMSS.sql.gz`
- Location: `backups/` (project root)
- Rotation: Keep last 10, delete older

## Error Handling
- Use colored output: green for success, red for errors
- Exit codes: 0 success, 1 general error, 2 missing dependencies
