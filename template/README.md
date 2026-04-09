# {{PROJECT_NAME}}

> WordPress + Docker + Redis + Traefik production stack.

## Quick Start

```bash
make up        # Start all services
make test      # Verify connections
make status    # Check container health
```

## Stack

| Service | Image | Port |
|---------|-------|------|
| **WordPress** | PHP {{PHP_VERSION}} + Redis PECL | `{{DEV_DOMAIN}}` |
| **MySQL** | {{MYSQL_VERSION}} | `127.0.0.1:{{MYSQL_PORT}}` |
| **Redis** | 7-alpine | `127.0.0.1:{{REDIS_PORT}}` |
| **phpMyAdmin** | 5.2-apache | `{{PMA_DOMAIN}}` |

## Domains

| URL | Service |
|-----|---------|
| `https://{{DEV_DOMAIN}}` | WordPress site |
| `https://{{PANEL_DOMAIN}}` | Admin panel |
| `https://{{PMA_DOMAIN}}` | phpMyAdmin |

## Development

```bash
# Stack management
make up / down / restart / build / status / clean

# Logs
make logs / logs-wp / logs-mysql

# Database
make backup / shell-mysql

# Testing
make test          # Connection tests
make test-all      # All test suites
make test-panel    # Panel tests only
make test-dash     # Dashboard tests only

# Code quality
make lint          # All linters
make format        # Auto-fix formatting
```

## Configuration

- **Environment:** `.env` (auto-generated, gitignored)
- **Google APIs:** See [docs/GOOGLE-SETUP.md](docs/GOOGLE-SETUP.md)
- **Database:** `{{MYSQL_DATABASE}}`, user: `{{MYSQL_USER}}`, prefix: `{{TABLE_PREFIX}}`

## AI Ecosystem

This project includes a complete AI-assisted development setup for VS Code + GitHub Copilot:

- **12 instruction files** — Context-aware rules auto-loaded by file pattern
- **11 specialized agents** — Domain-specific AI personas
- **6 skills** — Reusable multi-step workflows (TDD, ship-feature, code-review)
- **16 prompt commands** — Quick-action slash commands
- **4 safety hooks** — Pre/post tool-use guardrails

## Security

- MySQL exposed only on `127.0.0.1:{{MYSQL_PORT}}`
- Redis with password authentication
- WordPress mu-plugin with 9 security features
- Non-default table prefix (`{{TABLE_PREFIX}}`)
- All secrets in `.env` (gitignored)

## Documentation

- [docs/GOOGLE-SETUP.md](docs/GOOGLE-SETUP.md) — Google API configuration guide
- [docs/README.md](docs/README.md) — Architecture and project documentation
