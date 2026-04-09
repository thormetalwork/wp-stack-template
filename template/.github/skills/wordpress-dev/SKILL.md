---
name: wordpress-dev
description: "Develop WordPress themes, plugins, and custom functionality. Use when creating pages, customizing themes, adding plugins, or building custom post types. Covers WPCS, bilingual content, and SEO."
argument-hint: "What to build (e.g., custom post type for portfolio, contact form)"
---

# WordPress Development — {{PROJECT_NAME}}

## When to Use
- Creating new WordPress pages or templates
- Developing custom themes or child themes
- Building or modifying plugins
- Creating custom post types
- Adding custom fields
- Implementing contact forms
- Configuring SEO meta tags and schema markup
- Setting up bilingual content (EN/ES)

## Environment
- **WordPress:** {{WP_VERSION}} on PHP {{PHP_VERSION}} + Apache
- **Database:** MySQL {{MYSQL_VERSION}}, db: `{{MYSQL_DATABASE}}`, prefix: `{{TABLE_PREFIX}}_`
- **Cache:** Redis 7 at `redis:6379`
- **Files:** `data/wordpress/wp-content/` (themes, plugins, uploads)
- **URL:** `{{DEV_DOMAIN}}`

## Procedures

### Create Custom Post Type
1. Create file: `data/wordpress/wp-content/mu-plugins/{{PROJECT_SLUG}}-post-types.php`
2. Register with `{{TABLE_PREFIX}}_` prefix: `register_post_type('{{TABLE_PREFIX}}_portfolio', [...])`
3. Add taxonomy if needed: `register_taxonomy('{{TABLE_PREFIX}}_project_type', ...)`
4. Flush rewrite rules: Visit Settings → Permalinks → Save

### Create Page Template
1. Create in theme: `data/wordpress/wp-content/themes/THEME/template-{name}.php`
2. Add template header: `/* Template Name: {Name} */`
3. Make bilingual: `__('Text', '{{TEXT_DOMAIN}}')`

### Add Custom Fields
Prefer ACF (if installed) or native `register_meta()`:
```php
function {{TABLE_PREFIX}}_register_meta_fields() {
    register_meta('post', '{{TABLE_PREFIX}}_project_value', [
        'type' => 'string',
        'single' => true,
        'show_in_rest' => true,
        'sanitize_callback' => 'sanitize_text_field',
    ]);
}
add_action('init', '{{TABLE_PREFIX}}_register_meta_fields');
```

### SEO Schema Markup
Add LocalBusiness JSON-LD to `functions.php`:
```php
function {{TABLE_PREFIX}}_local_business_schema() {
    $schema = [
        '@context' => 'https://schema.org',
        '@type' => 'LocalBusiness',
        'name' => '{{PROJECT_NAME}}',
        'url' => home_url(),
    ];
    echo '<script type="application/ld+json">' . wp_json_encode($schema) . '</script>';
}
add_action('wp_head', '{{TABLE_PREFIX}}_local_business_schema');
```

## Coding Standards
- All functions prefixed with `{{TABLE_PREFIX}}_`
- Text domain: `{{TEXT_DOMAIN}}`
- PHPDoc on all functions
- Follow WPCS (WordPress Coding Standards)
- Sanitize all input: `sanitize_text_field()`, `absint()`, `wp_kses_post()`
- Escape all output: `esc_html()`, `esc_attr()`, `esc_url()`
- Prepare all SQL: `$wpdb->prepare()`
