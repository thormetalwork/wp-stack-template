---
description: "Use when editing Docker files: Dockerfile, docker-compose.yml, container configuration."
applyTo: ["docker-compose.yml", "docker/**", "**/Dockerfile"]
---
# Docker Guidelines — {{PROJECT_NAME}}

## Services Architecture
- **MySQL {{MYSQL_VERSION}}**: Internal only (`127.0.0.1:{{MYSQL_PORT}}`), persistent volume at `data/mysql/`
- **Redis 7-alpine**: 64MB max, LRU eviction, WP Object Cache
- **WordPress**: Custom Dockerfile with PECL Redis, PHP {{PHP_VERSION}}-apache
- **phpMyAdmin**: Admin access via Traefik

## Required Patterns
- Every service MUST have a `healthcheck` with `interval`, `timeout`, `retries`
- Use `depends_on: { service: { condition: service_healthy } }` — never bare `depends_on`
- Container names use prefix `{{DOCKER_PREFIX}}_` (e.g., `{{DOCKER_PREFIX}}_wordpress`)
- MySQL MUST NOT be exposed to `0.0.0.0` — use `127.0.0.1:PORT` only
- Resource limits: set `mem_limit` for all services
- Networks: `{{PROJECT_SLUG}}-network` (internal), `traefik-public` (external)

## Environment
- All secrets via `.env` file (never hardcode)
- WordPress DB prefix: `{{TABLE_PREFIX}}`
