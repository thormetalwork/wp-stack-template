---
description: "Use when editing Google API integrations, external data fetching, OAuth tokens, cron sync, GA4, Search Console, Google Business Profile, Instagram Graph API, Maps Embed, reCAPTCHA verification, Schema Markup (JSON-LD), SEO Meta Tags, XML Sitemap, or Google Fonts."
applyTo:
  - data/wordpress/wp-content/plugins/{{PLUGIN_SLUG}}/includes/class-*-cron.php
  - data/wordpress/wp-content/plugins/{{PLUGIN_SLUG}}/includes/class-*-google-auth.php
  - data/wordpress/wp-content/mu-plugins/*-contact-form.php
  - data/wordpress/wp-content/mu-plugins/*-service-pages.php
  - data/wordpress/wp-content/mu-plugins/*-schema.php
  - data/wordpress/wp-content/mu-plugins/*-meta-tags.php
  - data/wordpress/wp-content/mu-plugins/*-sitemap.php
  - data/wordpress/wp-content/themes/*/functions.php
---
# Google & External API Integration Rules

## API Inventory

| API | File | Auth |
|-----|------|------|
| GA4 Data API | `class-{{PLUGIN_SLUG}}-cron.php` | OAuth2 via Google Auth class |
| Search Console | `class-{{PLUGIN_SLUG}}-cron.php` | OAuth2 via Google Auth class |
| Google Business Profile | `class-{{PLUGIN_SLUG}}-cron.php` | `GBP_API_KEY` env var |
| Instagram Graph API | `class-{{PLUGIN_SLUG}}-cron.php` | `IG_ACCESS_TOKEN` env var |
| Google Maps Embed | mu-plugin | `GCP_API_KEY` env var |
| reCAPTCHA Enterprise v3 | mu-plugin | `GCP_SERVER_API_KEY` env var |
| Schema Markup (JSON-LD) | mu-plugin | None (output only) |
| SEO Meta Tags & Open Graph | mu-plugin | None (output only) |
| XML Sitemap | mu-plugin | None (output only) |
| Google Fonts | theme `functions.php` + `theme.json` | Public CDN |

## OAuth2 Token Management

- Token endpoint: `https://oauth2.googleapis.com/token`
- Transient key: `{{TABLE_PREFIX}}google_access_token` (TTL ~55 min)
- Auto-refreshes via `GOOGLE_OAUTH_REFRESH_TOKEN`
- Use the Google Auth class `::api_post($url, $body)` — never call `wp_remote_post` directly for Google APIs

## Environment Variables (from docker-compose.yml)

```
GA4_PROPERTY_ID, GA4_MEASUREMENT_ID
GOOGLE_OAUTH_CLIENT_ID, GOOGLE_OAUTH_CLIENT_SECRET, GOOGLE_OAUTH_REFRESH_TOKEN
GSC_SITE_URL, GCP_API_KEY, GCP_SERVER_API_KEY
RECAPTCHA_SITE_KEY, GBP_API_KEY, IG_ACCESS_TOKEN
```

Always check `defined('CONSTANT')` or `getenv()` before using. Return early with empty array if missing.

## Cron Sync Pattern

- KPI storage: `{prefix}panel_kpis` table with upsert on `(metric, period, category)`
- Period format: `Y-m` (e.g., `2026-04`)
- JSON metrics: stored as transient `{{TABLE_PREFIX}}kpi_{category}_{metric}` (TTL 1 day)

## Security Rules

- **Never log or expose API keys** — use `wp_remote_post` with keys in headers/body only
- **reCAPTCHA**: score threshold = 0.5; fail open on network errors (log + allow submission)
- **Rate limiting**: 1 submission per IP per 3 minutes
- **Maps Embed**: sanitize address with `esc_attr()` before embedding in iframe URL

## Error Handling

- All API calls must check `is_wp_error($response)` and `wp_remote_retrieve_response_code()`
- Log failures with `error_log()` — never expose to frontend
- Placeholder APIs (GBP, Instagram) must return `array()` gracefully when config is missing

## Schema Markup (JSON-LD)

- **LocalBusiness** schema at `wp_head` priority 1 — global on every page
- **Service** schema at priority 2 — only on service page slugs
- **FAQPage** schema at priority 3 — per-service FAQs embedded in structured data
- **BreadcrumbList** schema — navigation path for Google search breadcrumbs
- Centralized JSON-LD output helper — `json_encode` + `<script type="application/ld+json">`
- Keep `@id` anchors consistent: `home_url('/#localbusiness')` for cross-referencing
- Provider always references `@id` of LocalBusiness (do not duplicate full data)

## SEO Meta Tags

- Title override via `pre_get_document_title` filter
- `<meta name="description">` based on per-slug SEO mapping array
- Open Graph: `og:site_name`, `og:locale`, `og:type`, `og:title`, `og:description`, `og:url`, `og:image`
- Twitter Card: `summary_large_image` with matching title/description/image
- `hreflang` tags: `en`, `es`, `x-default` — on pages and portfolio singles
- Canonical URL: on front page, singular posts, portfolio archives
- Add new pages to the SEO mapping array when creating service pages

## XML Sitemap

- Custom rewrite rule: `sitemap.xml` → `index.php?{prefix}_sitemap=1`
- Includes: all published pages + all published portfolio posts + portfolio archive
- Output: XML with `<urlset>`, `<url>`, `<loc>`, `<lastmod>` (ISO 8601)
- Submit to Google Search Console via `GSC_SITE_URL` domain property
- After adding new pages: flush rewrite rules if needed

## Google Fonts

- Loaded via theme `functions.php` with `wp_enqueue_style()` and `theme.json`
- CDN: `https://fonts.googleapis.com/css2?family=...&display=swap`
- Preconnect hints: `fonts.googleapis.com` + `fonts.gstatic.com` (crossorigin)
- CSP headers must whitelist both domains
- Do NOT self-host — Google Fonts CDN provides optimal caching and subsetting
