---
description: "Use when editing the lead management system: CRUD operations, lead history, status tracking, REST API endpoints, high-value alerts."
applyTo: "data/wordpress/wp-content/plugins/{{PLUGIN_SLUG}}/**"
---

# Lead System Guidelines

## Database Schema

| Table | Purpose |
|-------|---------|
| `{{TABLE_PREFIX}}panel_leads` | Main leads: id, name, email, phone, source, status, notes, lead_value, created_at, updated_at |
| `{{TABLE_PREFIX}}panel_lead_history` | Audit trail: id, lead_id, field_changed, old_value, new_value, changed_by, changed_at |

## Lead Statuses

Valid status flow: `new` → `contacted` → `quoted` → `won` / `lost`

Never skip statuses without logging the transition in `{{TABLE_PREFIX}}panel_lead_history`.

## Code Conventions

- All DB queries via `$wpdb->prepare()` — never interpolate user input
- Sanitize inputs: `sanitize_text_field()`, `sanitize_email()`, `intval()` for lead_value
- Prefix all functions and hooks with `{{TABLE_PREFIX}}`
- High-value threshold: leads with `lead_value >= 5000` trigger alert hooks

## REST API

- Namespace: `{{PLUGIN_SLUG}}/v1`
- Endpoints follow WordPress REST conventions with `permission_callback` on every route
- Return `WP_REST_Response` with proper HTTP status codes

## Testing

- Test files: `tests/test-lead-*.sh`
- Pattern: bash scripts with PASS/FAIL counters
- Test CRUD operations via `docker exec` PHP evaluation
