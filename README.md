# WP Stack Template

> Production-ready WordPress + Docker stack generator with automated security hardening, Redis object caching, Traefik reverse proxy, and a complete AI-assisted development ecosystem.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## What You Get

Run `./setup.sh` and in under 2 minutes you'll have:

| Layer | What's Included |
|-------|----------------|
| **Docker Stack** | WordPress + PHP 8.x, MySQL 8.0, Redis 7, phpMyAdmin — all with health checks, resource limits, and Traefik labels |
| **Security** | PHP hardening (disable_functions, secure cookies, expose_php=Off), Redis auth, WordPress mu-plugin with 9 security features, non-default table prefix |
| **DevOps** | Makefile with 20+ targets, backup/restore/cache scripts, CI pipeline (PHP lint, PHPCS, ESLint, PHPStan, Docker validation) |
| **QA** | ESLint 9, Prettier, PHPCS/WPCS, PHPStan, Husky pre-commit hooks, EditorConfig |
| **AI Ecosystem** | 11 specialized agents, 12 instruction files, 6 skills, 16 prompt commands, 4 safety hooks — all pre-configured for VS Code + GitHub Copilot |
| **Plugin Scaffold** | Custom admin panel plugin with REST API, custom roles, router, login/panel templates |
| **Tests** | 3 bash test suites (stack health, connections, plugin scaffold) with pass/fail counters |

## Quick Start

### Prerequisites

- Docker Engine 24+ & Docker Compose v2
- Traefik reverse proxy on `traefik-public` network (or modify compose file)
- Git, bash, openssl
- Optional: `gh` CLI for automatic GitHub repo creation

### Generate Your Project

```bash
git clone https://github.com/thormetalwork/wp-stack-template.git
cd wp-stack-template
./setup.sh
```

The interactive wizard will ask for:

| Variable | Example | Description |
|----------|---------|-------------|
| `PROJECT_NAME` | Acme Corp | Human-readable project name |
| `PROJECT_SLUG` | acme-corp | Kebab-case identifier |
| `DOCKER_PREFIX` | acme_dev | Docker container prefix |
| `PLUGIN_SLUG` | acme-panel | Admin panel plugin slug |
| `PLUGIN_CLASS_PREFIX` | Acme_Panel | PHP class prefix |
| `TEXT_DOMAIN` | acmecorp | WordPress i18n text domain |
| `TABLE_PREFIX` | acme | DB table & function prefix |
| `DEV_DOMAIN` | dev.acme.com | WordPress domain |
| `PANEL_DOMAIN` | panel-dev.acme.com | Admin panel domain |
| `PMA_DOMAIN` | pma-dev.acme.com | phpMyAdmin domain |
| `MYSQL_PORT` | 3311 | Local MySQL exposed port |
| `REDIS_PORT` | 6380 | Local Redis port (0 = no expose) |
| `PHP_VERSION` | 8.1 | PHP version (8.1, 8.2, 8.3) |
| `WP_VERSION` | 6.9 | WordPress version |
| `MYSQL_VERSION` | 8.0 | MySQL version |
| `NODE_VERSION` | 22 | Node.js version for QA tools |

After answering, `setup.sh` will:

1. Copy all template files to your output directory
2. Replace all `{{VARIABLES}}` with your values
3. Rename plugin directories and files to match your slug
4. Generate `.env` with secure random passwords and WordPress salts
5. Initialize git repository
6. Optionally create a GitHub repo via `gh` CLI

### Start Your Stack

```bash
cd /path/to/your-project
make up        # Start all services
make test      # Verify connections
make status    # Check container health
```

### Configure Google APIs (Post-Setup)

The stack supports 8 Google integrations out of the box. During `setup.sh`, you can enter API keys interactively or configure them later in `.env`.

| Integration | Required For | Status |
|-------------|-------------|--------|
| **Google Analytics 4** | Dashboard KPIs | Daily cron sync via OAuth2 |
| **Google Search Console** | SEO metrics | Daily cron sync via OAuth2 |
| **Google OAuth2** | GA4 + GSC APIs | Centralized token management |
| **reCAPTCHA Enterprise v3** | Contact form protection | Score-based bot detection |
| **Google Maps Embed** | Contact page map | Browser API key |
| **Google Fonts** | Typography | No setup needed (public CDN) |
| **Schema Markup (JSON-LD)** | Rich search results | No setup needed (mu-plugin) |
| **XML Sitemap** | Search indexing | Auto-generated, submit to GSC |

See **[docs/GOOGLE-SETUP.md](docs/GOOGLE-SETUP.md)** for the step-by-step configuration guide.

## Architecture

```
┌─────────────┐     ┌──────────────────────────────────────────┐
│   Traefik   │────▶│  project-network (internal)              │
│  (external) │     │  ┌──────────┐ ┌───────┐ ┌─────────────┐ │
└──────┬──────┘     │  │ WordPress│─│ MySQL │─│   Redis     │ │
       │            │  │ :80      │ │ :3306 │ │   :6379     │ │
       │            │  └──────────┘ └───────┘ └─────────────┘ │
       │            └──────────────────────────────────────────┘
       │
       ├──▶ dev.example.com       → WordPress
       ├──▶ panel-dev.example.com → Admin Panel
       └──▶ pma-dev.example.com   → phpMyAdmin
```

### Services

| Service | Image | Health Check | Resources |
|---------|-------|-------------|-----------|
| **WordPress** | Custom (wp + Redis PECL) | `curl -f wp-login.php` | 512M mem |
| **MySQL** | mysql:8.0 | `mysqladmin ping` | 512M mem |
| **Redis** | redis:7-alpine | `redis-cli ping` | 64M mem (LRU) |
| **phpMyAdmin** | phpmyadmin:latest | `curl -f /` | 256M mem |

### Security Features

The generated stack includes out-of-the-box:

- **PHP hardening**: `disable_functions`, `expose_php=Off`, secure session cookies
- **WordPress mu-plugin** with 9 security features:
  - XML-RPC disabled
  - REST API restricted to authenticated users
  - Version numbers removed
  - File editor disabled
  - Security headers (X-Frame-Options, X-Content-Type, etc.)
  - Author enumeration blocked
  - Application passwords restricted
  - Login rate limiting with proxy-aware IP detection
- **Redis** with password authentication
- **MySQL** exposed only on `127.0.0.1` (localhost)
- **Non-default** table prefix
- **Secrets** in `.env` (auto-gitignored)

## Daily Operations

```bash
# Stack management
make up             # Start stack
make down           # Stop stack
make restart        # Stop + start
make build          # Rebuild without cache
make status         # Container status
make logs           # Tail all logs
make logs-wp        # WordPress logs only
make logs-mysql     # MySQL logs only

# Database
make backup         # Backup with rotation (keeps 10)
make shell-mysql    # MySQL CLI

# Cache
bash scripts/clear-cache.sh   # Flush Redis

# Testing
make test           # Test all connections
make test-all       # Run all test suites

# Code quality
make lint           # Run all linters
make lint-php       # PHP syntax check
make lint-js        # ESLint
make lint-format    # Prettier check
make lint-phpcs     # WordPress coding standards
make lint-phpstan   # Static analysis
make format         # Auto-fix formatting
make fix            # Auto-fix lint issues

# Development
make shell-wp       # WordPress container shell
```

## Project Structure

```
your-project/
├── docker-compose.yml          # Service orchestration
├── docker/wordpress/Dockerfile # Custom WP image with Redis
├── .env                        # Secrets (auto-generated, gitignored)
├── .env.example                # Template for .env variables
├── Makefile                    # 20+ operational targets
├── BACKLOG.md                  # Ticket tracking (create after setup)
│
├── scripts/
│   ├── backup-database.sh      # mysqldump + gzip + rotation
│   ├── restore-database.sh     # Restore from .sql.gz backup
│   ├── clear-cache.sh          # Flush Redis cache
│   └── test-connections.sh     # Verify all services
│
├── tests/
│   ├── test-dock-001-stack-health.sh
│   ├── test-dock-002-connections.sh
│   └── test-wp-001-plugin-scaffold.sh
│
├── data/wordpress/wp-content/
│   ├── mu-plugins/{slug}-security.php    # Security hardening
│   └── plugins/{plugin-slug}/            # Admin panel plugin
│       ├── {plugin-slug}.php             # Main plugin file
│       ├── includes/
│       │   ├── class-{slug}-router.php   # URL router
│       │   ├── class-{slug}-api.php      # REST API
│       │   └── class-{slug}-roles.php    # Custom roles
│       └── templates/
│           ├── login.php                 # Login page
│           └── panel.php                 # Dashboard SPA
│
├── .github/
│   ├── copilot-instructions.md           # AI project context
│   ├── workflows/ci.yml                  # CI pipeline (4 jobs)
│   ├── hooks/                            # Safety hooks
│   ├── agents/           (11 agents)     # Specialized AI agents
│   ├── instructions/     (12 files)      # Context-aware instructions
│   ├── skills/           (6 skills)      # Reusable AI workflows
│   └── prompts/          (16 commands)   # Quick-action slash commands
│
└── QA configs
    ├── package.json, composer.json       # Dependencies
    ├── eslint.config.mjs, .phpcs.xml     # Linter configs
    ├── phpstan.neon, .prettierrc         # Analysis configs
    ├── .editorconfig, .nvmrc             # Editor configs
    └── .husky/pre-commit                 # Git hooks
```

## AI Ecosystem

This template includes a complete AI-assisted development setup for **VS Code + GitHub Copilot Chat**:

### Agents (11)
Specialized AI personas with restricted tools and focused expertise:

| Agent | Purpose |
|-------|---------|
| DevOps | Docker, infrastructure, deployment |
| WordPress Dev | Themes, plugins, PHP customization |
| TDD Developer | Test-driven development cycle |
| Security Auditor | Security analysis and hardening |
| Full Cycle Developer | End-to-end ticket implementation |
| Ticket Manager | Backlog and ticket management |
| Performance Analyst | Performance monitoring and optimization |
| SEO Specialist | SEO, local search, schema markup |
| Content Writer | Bilingual website copy and marketing |
| Dashboard Dev | KPI dashboards, Chart.js, data visualization |
| Client Reporter | Monthly reports, KPI summaries, client communications |

### Skills (6)
Reusable multi-step workflows:

| Skill | Workflow |
|-------|----------|
| `tdd-workflow` | RED → GREEN → REFACTOR cycle |
| `ship-feature` | Complete ticket implementation (10 phases) |
| `stack-management` | Docker lifecycle operations |
| `code-review` | Structured review with checklist |
| `ticket-management` | BACKLOG.md ticket CRUD |
| `wordpress-dev` | WordPress development patterns |

### Prompts (16)
Slash commands for common operations:

| Command | Action |
|---------|--------|
| `/ticket` | Create a new development ticket |
| `/ship` | Implement a ticket end-to-end |
| `/tests` | Generate TDD tests for a feature |
| `/code-review` | Run structured code review |
| `/test-stack` | Health check all services |
| `/backup-database` | Create database backup |
| `/deploy` | Safe deployment with verification |
| `/security-audit` | Full security audit |
| `/performance-check` | Performance analysis |
| `/backlog-status` | Backlog dashboard |
| `/cache-status` | Redis cache diagnostics |
| `/db-migrate` | Run pending database migrations |
| `/migrate-database` | Migrate DB between environments |
| `/seo-audit` | Comprehensive SEO analysis |
| `/new-page` | Create WordPress page with SEO |
| `/client-report` | Generate monthly client report |

### Instructions (12)
Auto-loaded context based on file patterns:

| File | Applies To |
|------|------------|
| `docker.instructions.md` | Dockerfile, docker-compose.yml |
| `wordpress.instructions.md` | PHP files in wp-content |
| `security.instructions.md` | All code generation |
| `scripts.instructions.md` | Shell scripts |
| `testing.instructions.md` | Test files |
| `env-validation.instructions.md` | .env files |
| `workflows.instructions.md` | BACKLOG.md, .github/ |
| `redis.instructions.md` | docker-compose.yml, clear-cache.sh |
| `google-apis.instructions.md` | API integration files |
| `leads.instructions.md` | Plugin lead management files |
| `documentation.instructions.md` | Markdown docs |
| `dashboard.instructions.md` | Dashboard HTML/JS/CSS |

## Extending the Template

### Add a New Service

1. Add to `docker-compose.yml` with health check and resource limits
2. Update `scripts/test-connections.sh`
3. Add Traefik labels if web-accessible
4. Update `Makefile` with new log/shell targets

### Add a Custom Post Type

```php
// data/wordpress/wp-content/mu-plugins/{slug}-post-types.php
function {prefix}_register_post_types() {
    register_post_type('{prefix}_portfolio', [
        'labels' => ['name' => __('Portfolio', '{text-domain}')],
        'public' => true,
        'show_in_rest' => true,
        'supports' => ['title', 'editor', 'thumbnail'],
    ]);
}
add_action('init', '{prefix}_register_post_types');
```

### Add a New Test Suite

```bash
# tests/test-{scope}-{num}-{description}.sh
#!/bin/bash
set -euo pipefail
PASS=0; FAIL=0

# Test functions here...

echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]] || exit 1
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Container won't start | `make logs` to check errors, verify `.env` exists |
| MySQL connection refused | Check `MYSQL_PORT` isn't in use: `lsof -i :PORT` |
| Redis auth error | Verify `REDIS_PASSWORD` in `.env` matches compose config |
| WordPress white screen | `make logs-wp` — check PHP errors, verify DB connection |
| Traefik not routing | Verify `traefik-public` network exists: `docker network ls` |
| Permission denied on scripts | `chmod +x scripts/*.sh` |
| phpMyAdmin auth fail | Check `PMA_BASICAUTH_USERNAME/PASSWORD` in `.env` |

### Create Traefik Network (if missing)

```bash
docker network create traefik-public
```

### Reset Everything

```bash
make clean       # Down + remove volumes (DESTRUCTIVE)
make build       # Fresh rebuild
make test        # Verify
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Follow TDD: write tests first, then implement
4. Ensure all checks pass: `make lint && make test`
5. Submit a PR

## License

MIT License — see [LICENSE](LICENSE) for details.

---

Built with the patterns and practices from real production WordPress stacks.
