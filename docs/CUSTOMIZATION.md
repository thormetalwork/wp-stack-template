# Customization Guide

## Template Variables

After running `setup.sh`, all `{{VARIABLE}}` placeholders are replaced with your project values. Here's the complete reference:

### Primary Variables (prompted by setup.sh)

| Variable | Type | Example | Used In |
|----------|------|---------|---------|
| `PROJECT_NAME` | Human name | My Project | docs, comments, branding |
| `PROJECT_SLUG` | kebab-case | my-project | file names, directories |
| `DOCKER_PREFIX` | snake_case | myproj_dev | container names, compose |
| `PLUGIN_SLUG` | kebab-case | myproj-panel | plugin directory, files |
| `PLUGIN_CLASS_PREFIX` | PascalCase | Myproj_Panel | PHP class names |
| `TEXT_DOMAIN` | slug | myproject | WordPress i18n |
| `TABLE_PREFIX` | short | mp | DB prefix, function prefix |
| `DEV_DOMAIN` | domain | dev.myproject.com | Traefik routing |
| `PANEL_DOMAIN` | domain | panel-dev.myproject.com | Traefik routing |
| `PMA_DOMAIN` | domain | pma-dev.myproject.com | Traefik routing |
| `MYSQL_PORT` | port | 3311 | compose port mapping |
| `REDIS_PORT` | port | 6380 | compose port mapping (0 = none) |
| `PHP_VERSION` | version | 8.1 | Dockerfile FROM |
| `WP_VERSION` | version | 6.9 | Dockerfile FROM |
| `MYSQL_VERSION` | version | 8.0 | compose image tag |
| `NODE_VERSION` | version | 22 | .nvmrc, CI |

### Derived Variables (computed by setup.sh)

| Variable | Derived From | Example |
|----------|-------------|---------|
| `MYSQL_DATABASE` | `PROJECT_SLUG` + `_wp` | myproject_wp |
| `MYSQL_USER` | `PROJECT_SLUG` | myproject |
| `TRAEFIK_ROUTER` | `DOCKER_PREFIX` | myproj_dev |

## Common Customizations

### Change PHP Version

Edit `docker/wordpress/Dockerfile` — first line:
```dockerfile
FROM wordpress:6.9-php8.2-apache
```

Then rebuild:
```bash
make build
```

### Add a New Docker Service

1. Add service to `docker-compose.yml` with:
   - Health check
   - Resource limits (`deploy.resources.limits`)
   - Network attachment
   - `depends_on` with `condition: service_healthy`

2. Add Traefik labels if web-accessible:
   ```yaml
   labels:
     - "traefik.enable=true"
     - "traefik.http.routers.{name}.rule=Host(`{domain}`)"
     - "traefik.http.routers.{name}.entrypoints=websecure"
     - "traefik.http.routers.{name}.tls.certresolver=letsencrypt"
   ```

3. Update `scripts/test-connections.sh` with health check
4. Add log/shell targets to `Makefile`

### Add WordPress Plugin

Drop the plugin into `data/wordpress/wp-content/plugins/` and activate:

```bash
make shell-wp
wp plugin activate my-plugin
```

Or add to `data/wordpress/wp-content/mu-plugins/` for auto-loaded must-use plugins.

### Modify Security Rules

Edit `data/wordpress/wp-content/mu-plugins/{slug}-security.php`:

- To allow REST API for specific routes, modify the `rest_authentication_errors` filter
- To change login rate limit, adjust `MAX_ATTEMPTS` and `WINDOW_SECONDS` constants
- To add security headers, extend the `send_headers` callback

### Add Custom Ticket Scopes

Edit `.github/skills/ticket-management/SKILL.md`:

Add new scopes to the scope table:
```markdown
| `LEAD` | Leads — CRM, pipeline |
| `BRAND` | Branding — design |
```

### Switch to No-Traefik Setup

Remove Traefik labels from `docker-compose.yml` and expose WordPress directly:

```yaml
wordpress:
  ports:
    - "8080:80"
```

Remove the `traefik-public` network references.

### Add WooCommerce

1. Install WooCommerce plugin
2. Add new ticket scope `SHOP` for e-commerce tickets
3. Create `.github/instructions/woocommerce.instructions.md` with WC-specific rules
4. Add relevant security rules for payment processing

## Environment Configuration

### .env Variables Reference

| Variable | Required | Description |
|----------|----------|-------------|
| `MYSQL_ROOT_PASSWORD` | Yes | MySQL root password |
| `MYSQL_DATABASE` | Yes | Database name |
| `MYSQL_USER` | Yes | Application DB user |
| `MYSQL_PASSWORD` | Yes | Application DB password |
| `WORDPRESS_DB_HOST` | Yes | Always `mysql` |
| `WORDPRESS_DB_USER` | Yes | Same as MYSQL_USER |
| `WORDPRESS_DB_PASSWORD` | Yes | Same as MYSQL_PASSWORD |
| `WORDPRESS_DB_NAME` | Yes | Same as MYSQL_DATABASE |
| `WORDPRESS_TABLE_PREFIX` | Yes | Non-default prefix |
| `REDIS_PASSWORD` | Yes | Redis auth password |
| `WORDPRESS_CONFIG_EXTRA` | Yes | PHP constants for wp-config |
| `PMA_BASICAUTH_USERNAME` | Yes | phpMyAdmin auth user |
| `PMA_BASICAUTH_PASSWORD` | Yes | phpMyAdmin auth password |
| WordPress salts (8) | Yes | AUTH_KEY, SECURE_AUTH_KEY, etc. |
