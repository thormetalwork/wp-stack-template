---
description: "Use when editing WordPress PHP files, themes, plugins, wp-config, or WordPress customizations."
applyTo: ["data/wordpress/**/*.php", "data/wordpress/wp-content/**"]
---
# WordPress Guidelines — {{PROJECT_NAME}}

## Coding Standards
- Follow WordPress Coding Standards (WPCS)
- Use `{{TABLE_PREFIX}}` prefix for all custom functions, hooks, and options
- Table prefix is `{{TABLE_PREFIX}}` (non-default for security)
- PHP {{PHP_VERSION}} compatibility required

## Security
- Always escape output: `esc_html()`, `esc_attr()`, `esc_url()`, `wp_kses()`
- Always sanitize input: `sanitize_text_field()`, `absint()`, `wp_unslash()`
- Use nonces for forms: `wp_nonce_field()` / `wp_verify_nonce()`
- Never use `$_GET`/`$_POST` directly without sanitization
- Database queries: use `$wpdb->prepare()` always

## Bilingual Content (EN/ES)
- All user-facing strings must be translatable: `__()`, `_e()`, `esc_html__()`
- Text domain: `{{TEXT_DOMAIN}}`

## Redis Object Cache
- Redis is available at `redis:6379` (container name)
- Use `wp_cache_get()` / `wp_cache_set()` — Redis handles persistence
- Never flush cache in production without reason
