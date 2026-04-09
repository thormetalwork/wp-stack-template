---
name: stack-management
description: "Manage the {{PROJECT_NAME}} Docker stack lifecycle: start, stop, rebuild, backup, restore, test connections, clear cache, monitor logs."
argument-hint: "Operation to perform (e.g., deploy, backup, troubleshoot redis)"
---

# Stack Management — {{PROJECT_NAME}}

## When to Use
- Starting, stopping, or restarting the Docker stack
- Rebuilding containers after Dockerfile or compose changes
- Creating or restoring database backups
- Testing service connectivity
- Clearing Redis cache
- Troubleshooting container issues
- Monitoring logs for errors

## Stack Services

| Service | Container | Health Check | Port |
|---------|-----------|-------------|------|
| MySQL {{MYSQL_VERSION}} | {{DOCKER_PREFIX}}_mysql | `mysqladmin ping` | 127.0.0.1:{{MYSQL_PORT}} |
| Redis 7 | {{DOCKER_PREFIX}}_redis | `redis-cli ping` | internal |
| WordPress {{WP_VERSION}} | {{DOCKER_PREFIX}}_wordpress | `curl wp-login.php` | via Traefik |
| phpMyAdmin | {{DOCKER_PREFIX}}_phpmyadmin | `curl /` | via Traefik |

## Procedures

### Start Stack
```bash
make up
make test    # Verify all healthy
```

### Safe Deploy (with backup)
```bash
make backup  # Always backup first
make build   # Rebuild without cache
make test    # Verify connections
make logs    # Check for errors
```

### Troubleshoot Service
1. Check status: `make status`
2. Check logs: `make logs` or `make logs-wp` / `make logs-mysql`
3. Enter container: `make shell-wp` or `make shell-mysql`
4. Test connections: `make test`
5. If needed, restart: `make restart`

### Database Backup & Restore
- Backup: `make backup` → Creates `/backups/{MYSQL_DATABASE}_YYYYMMDD_HHMMSS.sql.gz`
- Restore: `bash scripts/restore-database.sh /backups/FILENAME.sql.gz`
- Rotation: Keeps last 10 backups automatically

### Clear Cache
```bash
bash scripts/clear-cache.sh    # Flushes Redis cache
```

### Emergency Recovery
1. `make backup` (if MySQL is accessible)
2. `make down`
3. Check `docker-compose.yml` and `.env` for issues
4. `make build`
5. `make test`
6. If DB corrupt: `bash scripts/restore-database.sh /backups/LATEST.sql.gz`

## Reference Files
- [docker-compose.yml](../../docker-compose.yml)
- [Dockerfile](../../docker/wordpress/Dockerfile)
- [Backup script](../../scripts/backup-database.sh)
- [Test script](../../scripts/test-connections.sh)
