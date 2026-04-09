---
description: "Security-by-design rules for all code generation. Covers OWASP Top 10, input validation, output encoding, authentication, and infrastructure hardening."
applyTo: ["**/*.php", "**/*.js", "**/*.sh", "docker-compose.yml", "docker/**", "scripts/**"]
---
# Security Instructions — {{PROJECT_NAME}}

## OWASP Top 10 Compliance

### A01 — Broken Access Control
- Every REST endpoint MUST verify `current_user_can()` or custom capability
- Use WordPress nonces (`wp_verify_nonce()`) for all state-changing operations
- Never trust client-provided user IDs

### A02 — Cryptographic Failures
- Secrets MUST come from environment variables
- Never hardcode credentials, API keys, or salts in source code
- Use `wp_hash_password()` / `wp_check_password()` — never `md5()` or `sha1()`

### A03 — Injection
- **SQL:** Always use `$wpdb->prepare()` with placeholders (`%s`, `%d`)
- **XSS:** Escape all output — `esc_html()`, `esc_attr()`, `esc_url()`, `wp_kses_post()`
- **Command:** Never pass user input to `exec()`, `shell_exec()`, `system()`
- **JavaScript:** Never use `innerHTML` with unsanitized data

### A05 — Security Misconfiguration
- `WP_DEBUG` must default to `0` (controlled via env var)
- Redis MUST require authentication (`--requirepass`)
- phpMyAdmin MUST be behind BasicAuth + HTTPS

## PHP Patterns

```php
// ✅ Correct: prepared query
$wpdb->get_results( $wpdb->prepare(
    "SELECT * FROM {$wpdb->prefix}table WHERE status = %s", $status
) );

// ✅ Correct: escaped output
echo esc_html( $data->name );

// ✅ Correct: nonce verification
if ( ! wp_verify_nonce( $_POST['_nonce'], 'action' ) ) {
    wp_die( 'Security check failed.' );
}
```

## Shell Script Patterns

```bash
# ✅ Correct: quote all variables
docker exec {{DOCKER_PREFIX}}_redis redis-cli -a "$REDIS_PASSWORD" --no-auth-warning FLUSHDB

# ✅ Correct: validate .env before operations
[[ -f .env ]] || { echo "ERROR: .env not found" >&2; exit 1; }
```

## Docker / Infrastructure

- All services MUST have health checks
- Database ports: bind to `127.0.0.1` only
- Use `MYSQL_PWD` env var instead of `-p$PASSWORD` in commands
- Redis: use `FLUSHDB` (current database), never `FLUSHALL`
