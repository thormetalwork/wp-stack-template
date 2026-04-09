---
description: "Use when editing the client executive dashboard: HTML, CSS, JavaScript, charts, KPIs, data visualization. Covers Chart.js, responsive design, and client-facing UI."
---
# Dashboard Guidelines

## Tech Stack
- HTML5 + CSS3 (inline styles, no external CSS framework)
- Vanilla JavaScript (no React/Vue/Angular)
- Chart.js 4.x for data visualization
- Zero npm dependencies

## Dashboard Sections
1. **Overview** — KPIs, leads by channel chart, impressions sparkline
2. **Google Business Profile** — Reviews, impressions, actions, keyword tracking
3. **Website** — Sessions, conversion rate, top pages
4. **Leads** — Pipeline value, lead table with status tracking
5. **Instagram** — Followers, reach, engagement, top posts
6. **Alerts** — Actionable items requiring attention

## Patterns
- Tab-based navigation with JavaScript
- Responsive design: mobile-first
- Data format: numbers with locale formatting
- Currency: USD with `$` prefix
- Chart.js configuration: use brand accent as primary color, dark as secondary

## API Integration
- Google Business Profile API → reviews, impressions, actions
- Google Analytics 4 → sessions, conversions, pages
- Instagram Graph API → followers, reach, engagement
- Backend proxy recommended for API key security

## Constraints
- NEVER add npm dependencies or build tools
- NEVER use external CSS frameworks
- NEVER hardcode API keys in HTML/JS
- Always maintain responsive design (mobile-first)
