# Troubleshooting

## Common Issues

### Stack Won't Start

**Symptom**: `make up` fails or containers restart repeatedly.

**Diagnosis**:
```bash
make status        # Check which container is failing
make logs          # See error messages
docker compose config  # Validate compose file
```

**Common causes**:
- `.env` file missing → run `cp .env.example .env` and fill values
- Port conflict → check with `lsof -i :PORT` or `ss -tlnp | grep PORT`
- Traefik network missing → `docker network create traefik-public`
- Previous data with different credentials → `make clean` (destructive!)

---

### MySQL Connection Refused

**Symptom**: WordPress shows "Error establishing a database connection".

**Diagnosis**:
```bash
docker compose logs mysql | tail -20
docker compose exec mysql mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" ping
```

**Common causes**:
- MySQL still initializing (wait 30s on first start)
- Wrong credentials in `.env`
- `data/mysql/` has data from different MySQL version → backup and clean

**Fix**:
```bash
make backup                    # If possible
docker compose down -v         # Remove volumes
rm -rf data/mysql/*            # Clean data dir
make up                        # Fresh start
```

---

### Redis Authentication Error

**Symptom**: `NOAUTH Authentication required` in WordPress logs.

**Diagnosis**:
```bash
docker compose exec redis redis-cli -a "$REDIS_PASSWORD" ping
```

**Common causes**:
- `REDIS_PASSWORD` in `.env` doesn't match compose command
- WP-Redis plugin not configured with password

**Fix**: Verify `REDIS_PASSWORD` is consistent in:
1. `.env` file
2. `docker-compose.yml` → redis command `--requirepass`
3. `wp-config.php` → `WP_REDIS_PASSWORD` constant

---

### WordPress White Screen (WSOD)

**Symptom**: Blank white page, no error visible.

**Diagnosis**:
```bash
make logs-wp | tail -50
make shell-wp
wp --allow-root eval "phpinfo();"
```

**Common causes**:
- PHP fatal error (check logs)
- Memory limit exceeded → increase in Dockerfile's `uploads.ini`
- Plugin conflict → disable all plugins via shell:
  ```bash
  make shell-wp
  wp --allow-root plugin deactivate --all
  ```

---

### phpMyAdmin 403 / Auth Failed

**Symptom**: Can't access phpMyAdmin, gets 403 or password prompt loops.

**Diagnosis**:
```bash
# Check BasicAuth credentials
grep PMA_BASICAUTH .env
```

**Common causes**:
- `PMA_BASICAUTH_PASSWORD` contains special characters that need escaping
- Traefik middleware not properly configured

**Fix**: Use simple alphanumeric passwords for BasicAuth, or encode special chars.

---

### Backup Script Fails

**Symptom**: `make backup` errors or creates empty files.

**Diagnosis**:
```bash
docker compose exec mysql mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" ping
ls -la backups/
```

**Common causes**:
- MySQL not healthy → wait and retry
- `backups/` directory doesn't exist → `mkdir -p backups`
- Disk space full → `df -h`

---

### CI Pipeline Fails

**Symptom**: GitHub Actions checks fail.

**Check each job**:

| Job | Likely Fix |
|-----|-----------|
| PHP Lint | Fix syntax: `find data/wordpress/wp-content -name "*.php" -exec php -l {} \;` |
| PHPCS | Follow WPCS: `composer run phpcs` |
| ESLint | Fix JS: `npx eslint --fix` |
| PHPStan | Fix type issues: `composer run phpstan` |
| Docker Validate | Fix compose: `docker compose config` |

---

### Pre-commit Hook Blocks Commit

**Symptom**: `git commit` fails with lint errors.

**Fix the errors** (recommended):
```bash
make lint          # See all issues
make format        # Auto-fix formatting
make fix           # Auto-fix lint issues
```

**Skip temporarily** (not recommended):
```bash
git commit --no-verify -m "wip: temporary commit"
```

---

### Container Resource Limits

**Symptom**: Container OOM-killed or sluggish.

**Check current usage**:
```bash
docker stats --no-stream
```

**Adjust in `docker-compose.yml`**:
```yaml
deploy:
  resources:
    limits:
      memory: 1G      # Increase from 512M
```

Then `make build`.

---

## Recovery Procedures

### Full Stack Reset
```bash
make backup          # Save current data
make clean           # Down + remove volumes
make build           # Rebuild from scratch
make test            # Verify
```

### Restore from Backup
```bash
bash scripts/restore-database.sh backups/FILENAME.sql.gz
bash scripts/clear-cache.sh
make test
```

### Emergency Container Access
```bash
# If WordPress container won't start, run manually:
docker compose run --rm wordpress bash

# If MySQL won't start, check logs:
docker compose logs mysql --tail 100
```

## Getting Help

1. Check this troubleshooting guide
2. Review `make logs` output
3. Search the [WordPress Docker Hub](https://hub.docker.com/_/wordpress) docs
4. Use `@devops` agent in Copilot Chat: describe the issue
5. Use `/test-stack` prompt to run full diagnostics
