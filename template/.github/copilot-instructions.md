# {{PROJECT_NAME}} — Project Guidelines

## Project Overview

{{PROJECT_NAME}} is a Docker-based production stack.

**Stack:** WordPress {{WP_VERSION}} + PHP {{PHP_VERSION}} + MySQL {{MYSQL_VERSION}} + Redis 7 + Traefik reverse proxy.

## Architecture

```
┌─────────────┐     ┌──────────────────────────────────────────┐
│   Traefik   │────▶│  {{PROJECT_SLUG}}-network (internal)     │
│  (external) │     │  ┌──────────┐ ┌───────┐ ┌─────────────┐ │
└──────┬──────┘     │  │ WordPress│─│ MySQL │─│   Redis     │ │
       │            │  │ :80      │ │ :3306 │ │   :6379     │ │
       │            │  └──────────┘ └───────┘ └─────────────┘ │
       │            └──────────────────────────────────────────┘
       │
       ├──▶ {{DEV_DOMAIN}}           → WordPress
       ├──▶ {{PANEL_DOMAIN}}         → Admin Panel (WordPress plugin)
       └──▶ {{PMA_DOMAIN}}           → phpMyAdmin
```

**Key decisions:**
- MySQL exposed only on `127.0.0.1:{{MYSQL_PORT}}` (local access)
- Redis: 64MB limit, LRU eviction policy for WP Object Cache
- WordPress custom Dockerfile with PECL Redis extension
- MySQL, Redis, WordPress have health checks with retries; phpMyAdmin has health check + depends on MySQL healthy

## Code Style & Conventions

- **Language:** Bilingual EN/ES — all user-facing content must support both languages
- **PHP:** WordPress coding standards (WPCS)
- **Shell scripts:** Use `set -e`, quote variables, validate `.env` before operations
- **HTML/CSS/JS:** Vanilla JS, no frameworks; Chart.js 4.x for visualizations
- **Docker:** Use health checks, depend on `service_healthy`, limit resources

## Build and Test

```bash
# Stack management
make up          # Start stack
make down        # Stop stack
make restart     # Stop + start
make build       # Rebuild without cache
make status      # Show container status
make clean       # Down + remove volumes

# Logs
make logs        # Tail all logs
make logs-wp     # Tail WordPress only
make logs-mysql  # Tail MySQL only

# Database & cache
make backup      # Backup database (10-file rotation)
make shell-wp    # WordPress container shell
make shell-mysql # MySQL container shell

# Testing
make test        # Test all connections
make test-all    # Run ALL test suites

# Code quality
make lint        # Run all linters
make lint-php    # PHP syntax check
make lint-js     # ESLint
make lint-format # Prettier check
make lint-phpcs  # WordPress coding standards
make lint-phpstan # Static analysis
make format      # Auto-fix formatting
make fix         # Auto-fix lint issues
```

## Development Workflow

- **Tickets:** `BACKLOG.md` is the single source of truth. Format: `TICKET-{SCOPE}-{NUM}`
- **Branching:** `main` ← `dev` ← `feat/TICKET-XXX-short-desc` (also `fix/`, `hotfix/`)
- **Commits:** `{type}(TICKET-XXX): description` (types: feat, fix, refactor, test, docs, chore)
- **TDD mandatory:** RED → GREEN → REFACTOR for all features
- **Tests:** Bash scripts in `tests/` using pass/fail counters pattern. Naming: `test-{scope}-{num}-{description}.sh`
- **Acceptance criteria:** Gherkin format (Given/When/Then) in every ticket

## Environment

- Secrets in `.env` (never commit — in `.gitignore`)
- Database: `{{MYSQL_DATABASE}}`, user: `{{MYSQL_USER}}`, prefix: `{{TABLE_PREFIX}}`
- Backups: `/backups/` with 10-file rotation

## File Structure

| Path | Purpose |
|------|---------|
| `docker-compose.yml` | Service orchestration (4 services) |
| `docker/wordpress/Dockerfile` | Custom WP image with Redis PECL |
| `Makefile` | Operational targets (stack, test, lint) |
| `.env` / `.env.example` | Secrets (gitignored) / variable template |
| `scripts/` | Operational scripts (backup, restore, test, cache) |
| `tests/` | Bash test scripts (TDD, integration) |
| `data/wordpress/` | WordPress files (volume mount) |
| `data/mysql/` | MySQL data (volume mount) |
| `docs/` | Project documentation |
| `.github/` | AI ecosystem (instructions, agents, skills, prompts, hooks, CI) |
| `package.json` / `composer.json` | JS + PHP dependencies and QA tools |
| `BACKLOG.md` | All tickets with status, priorities, and dependencies |

## CI Pipeline

GitHub Actions (`.github/workflows/ci.yml`) runs on push to `main`, `dev`, `feat/**`, `fix/**`:
- **lint-php** — PHP syntax + PHPCS/WPCS (strict on `main`, warnings on branches)
- **lint-js** — ESLint + Prettier format check
- **php-static-analysis** — PHPStan (strict on `main`)
- **validate-docker** — `docker compose config` syntax validation

## Security

- Never expose database credentials in code or logs
- MySQL only on localhost, external access via phpMyAdmin + Traefik
- WordPress table prefix `{{TABLE_PREFIX}}` (non-default)
- All `.env`, `data/`, `backups/`, `*.sql.gz` in `.gitignore`

## AI Customization Ecosystem

This project has a comprehensive `.github/` setup — see files before creating new ones:

| Primitive | Count | Location |
|-----------|-------|----------|
| Instructions | 12 | `.github/instructions/` — auto-loaded by `applyTo` file patterns |
| Agents | 11 | `.github/agents/` — domain-specific with restricted tool sets |
| Skills | 6 | `.github/skills/` — reusable workflows (TDD, code-review, ship-feature, stack-mgmt, tickets, WP) |
| Prompts | 16 | `.github/prompts/` — quick-action slash commands |
| Hooks | 4 | `.github/hooks/` — safety-checks.json + php-lint-check.sh + format-on-save.sh + sql-guard.sh |
