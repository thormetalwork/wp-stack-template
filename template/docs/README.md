# {{PROJECT_NAME}} — Documentation

## Architecture

```
┌─────────────┐     ┌──────────────────────────────────────────┐
│   Traefik   │────▶│  Internal Network                        │
│  (external) │     │  ┌──────────┐ ┌───────┐ ┌─────────────┐ │
└──────┬──────┘     │  │ WordPress│─│ MySQL │─│   Redis     │ │
       │            │  │ :80      │ │ :3306 │ │   :6379     │ │
       │            │  └──────────┘ └───────┘ └─────────────┘ │
       │            └──────────────────────────────────────────┘
       │
       ├──▶ {{DEV_DOMAIN}}       → WordPress
       ├──▶ {{PANEL_DOMAIN}}     → Admin Panel
       └──▶ {{PMA_DOMAIN}}       → phpMyAdmin
```

## Services

| Service | Image | Health Check | Memory |
|---------|-------|-------------|--------|
| WordPress | Custom (WP + Redis PECL) | `curl -f wp-login.php` | 512M |
| MySQL | mysql:{{MYSQL_VERSION}} | `mysqladmin ping` | 512M |
| Redis | redis:7-alpine | `redis-cli ping` | 64M (LRU) |
| phpMyAdmin | phpmyadmin:5.2-apache | `curl -f /` | 256M |

## Key Directories

| Path | Purpose |
|------|---------|
| `docker-compose.yml` | Service orchestration |
| `docker/wordpress/Dockerfile` | Custom WP image with Redis PECL |
| `.env` | Secrets (gitignored) |
| `scripts/` | Operational scripts (backup, restore, cache, tests) |
| `tests/` | Bash test scripts |
| `data/wordpress/wp-content/mu-plugins/` | Must-use plugins (security, SEO) |
| `data/wordpress/wp-content/plugins/{{PLUGIN_SLUG}}/` | Admin panel plugin |
| `.github/` | AI ecosystem (agents, instructions, skills, prompts, hooks) |
| `docs/` | Project documentation |

## External Integrations

See [GOOGLE-SETUP.md](GOOGLE-SETUP.md) for configuration details.

| Integration | Status | Purpose |
|-------------|--------|---------|
| Google Analytics 4 | Configured in `.env` | Dashboard KPIs via OAuth2 |
| Google Search Console | Configured in `.env` | SEO metrics via OAuth2 |
| reCAPTCHA Enterprise v3 | Configured in `.env` | Contact form protection |
| Google Maps Embed | Configured in `.env` | Contact page map |
| Schema Markup (JSON-LD) | Active (mu-plugin) | Rich search results |
| SEO Meta Tags | Active (mu-plugin) | Title, OG, hreflang, canonical |
| XML Sitemap | Active (mu-plugin) | Search engine indexing |
| Google Fonts | Active (theme) | Typography via CDN |

## CI Pipeline

GitHub Actions runs on push to `main`, `dev`, `feat/**`, `fix/**`:

1. **lint-php** — PHP syntax + PHPCS/WPCS
2. **lint-js** — ESLint + Prettier format check
3. **php-static-analysis** — PHPStan
4. **validate-docker** — `docker compose config` validation

## Development Workflow

- **Tickets:** `BACKLOG.md` — Format: `TICKET-{SCOPE}-{NUM}`
- **Branching:** `main` ← `dev` ← `feat/TICKET-XXX-short-desc`
- **Commits:** `{type}(TICKET-XXX): description`
- **TDD mandatory:** RED → GREEN → REFACTOR
- **Tests:** Bash scripts in `tests/` with pass/fail counters
