---
description: "Run pending database migrations for the plugin, verify schema, and report status."
agent: "agent"
---
# Database Migration Runner

Execute pending database migrations for the {{PLUGIN_SLUG}} plugin.

## Steps

1. **Check current DB version** — Run in the WordPress container:
   ```bash
   docker exec {{DOCKER_PREFIX}}_wordpress wp option get {{TABLE_PREFIX}}panel_db_version --allow-root 2>/dev/null || echo "0"
   ```

2. **Check target version** — Read `DB_VERSION` constant from the plugin's data class.

3. **List pending migrations** — Compare current vs target. Migration files are in `plugins/{{PLUGIN_SLUG}}/migrations/`.

4. **Create backup before migrating**:
   ```bash
   make backup
   ```

5. **Trigger migration** — Visit any wp-admin page (auto-triggers via `admin_init`) or force via WP CLI.

6. **Verify schema** — Check all tables exist:
   ```bash
   docker exec {{DOCKER_PREFIX}}_mysql mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" \
     -e "SHOW TABLES LIKE '{{TABLE_PREFIX}}panel_%';"
   ```

7. **Report** — Display: current version → new version, tables created/modified, any errors.

## Migration Pattern Reference

New migrations go in `migrations/NNN-description.php`:
- Receive `$wpdb`, `$prefix`, `$charset_collate` as globals
- Use `dbDelta()` for CREATE TABLE (idempotent)
- Use `SHOW COLUMNS` + `ALTER TABLE` for column additions (idempotent)
- Update `DB_VERSION` constant in the data class after adding
