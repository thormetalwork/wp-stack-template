---
description: "Use when editing .env, .env.example, or environment configuration files."
applyTo: ["**/.env*", "**/docker-compose.yml"]
---
# Environment Configuration Guidelines

## Required Variables
All `.env` files MUST define these variables (see `.env.example` for template):
- `MYSQL_ROOT_PASSWORD` — strong, unique, never reuse
- `MYSQL_DATABASE` — must be `{{MYSQL_DATABASE}}`
- `MYSQL_USER` — must be `{{MYSQL_USER}}`
- `MYSQL_PASSWORD` — strong, unique
- `WORDPRESS_DB_HOST` — must be `mysql` (Docker service name)
- `WORDPRESS_TABLE_PREFIX` — must be `{{TABLE_PREFIX}}`

## Security Rules
- NEVER commit `.env` — it's in `.gitignore`
- NEVER use default passwords like `CHANGE_ME`, `password`, `root`, `admin`
- Passwords MUST be 16+ characters with mixed case, numbers, symbols

## Validation Pattern
```bash
set -e
[[ -f .env ]] || { echo "ERROR: .env not found"; exit 1; }
source .env
[[ -n "$MYSQL_PASSWORD" ]] || { echo "ERROR: MYSQL_PASSWORD not set"; exit 1; }
```
