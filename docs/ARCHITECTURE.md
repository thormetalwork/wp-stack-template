# Architecture

## System Overview

This stack follows a Docker-centric architecture with Traefik as the entry point, routing traffic to WordPress via domain-based rules.

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────┐
│                   Traefik                        │
│            (reverse proxy + TLS)                 │
│  ┌──────────┬──────────────┬──────────────────┐ │
│  │ Host A   │   Host B     │    Host C        │ │
│  └────┬─────┴──────┬───────┴────────┬─────────┘ │
└───────┼────────────┼────────────────┼───────────┘
        │            │                │
        ▼            ▼                ▼
   WordPress    Admin Panel      phpMyAdmin
        │
   ┌────┴────┐
   │         │
   ▼         ▼
 MySQL    Redis
```

## Service Details

### WordPress (Application)

- **Image**: Custom Dockerfile extending `wordpress:{VERSION}-php{PHP_VERSION}-apache`
- **Extensions**: PECL Redis, production PHP config
- **Volume**: `./data/wordpress` mounted for persistent files
- **Depends on**: MySQL (healthy) + Redis (healthy)
- **Role**: Serves the website and REST API

### MySQL (Database)

- **Image**: `mysql:{VERSION}`
- **Exposed**: Only on `127.0.0.1:{PORT}` (never `0.0.0.0`)
- **Volume**: `./data/mysql` for persistent data
- **Health check**: `mysqladmin ping` every 10s
- **Auth**: Separate root + application user credentials

### Redis (Cache)

- **Image**: `redis:7-alpine`
- **Memory**: 64MB max with `allkeys-lru` eviction
- **Auth**: Password-protected via `requirepass`
- **Role**: WordPress object cache (WP-Redis plugin)
- **Not exposed**: Internal network only

### phpMyAdmin (Database UI)

- **Image**: `phpmyadmin:latest`
- **Auth**: Traefik BasicAuth middleware
- **Purpose**: Database management UI
- **Resource limit**: 256MB memory

## Network Topology

```
traefik-public (external)
    │
    ├── WordPress    ← Traefik routes by Host header
    ├── phpMyAdmin   ← Traefik routes by Host header
    │
project-network (internal)
    │
    ├── WordPress ──── MySQL (port 3306)
    ├── WordPress ──── Redis (port 6379)
    └── phpMyAdmin ─── MySQL (port 3306)
```

- **traefik-public**: External network shared with Traefik reverse proxy
- **project-network**: Internal network for inter-service communication
- MySQL and Redis are **never** exposed on the external network

## Data Flow

### Web Request
```
Browser → Traefik → WordPress → MySQL/Redis → Response
```

### Cache Flow
```
WordPress → Check Redis → HIT → Return cached
                        → MISS → Query MySQL → Store in Redis → Return
```

### Backup Flow
```
Cron/Manual → mysqldump → gzip → /backups/ → Rotate (keep 10)
```

## File Ownership

| Path | Managed By | Persisted |
|------|-----------|-----------|
| `data/wordpress/` | Docker volume | Yes — WordPress core + content |
| `data/mysql/` | Docker volume | Yes — MySQL datadir |
| `backups/` | Backup script | Yes — compressed SQL dumps |
| `.env` | setup.sh / manual | Yes — but gitignored |
