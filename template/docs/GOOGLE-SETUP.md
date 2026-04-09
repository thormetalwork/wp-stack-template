# Google & External API Setup Guide

Step-by-step configuration for all Google integrations in your stack.

> All API keys go in `.env` — never commit credentials to git.

---

## Prerequisites

1. A [Google Cloud Console](https://console.cloud.google.com/) project
2. Billing enabled on the GCP project
3. A [Google Analytics 4](https://analytics.google.com/) property for your site
4. A [Google Search Console](https://search.google.com/search-console) verified property

---

## 1. Google Cloud Project Setup

```
1. Go to https://console.cloud.google.com/
2. Create a new project (or select existing)
3. Note the Project ID — you'll need it for reCAPTCHA
```

### Enable Required APIs

In **APIs & Services → Library**, enable:

| API | Used For |
|-----|----------|
| Maps Embed API | Contact page map embed |
| reCAPTCHA Enterprise API | Contact form bot protection |
| Google Analytics Data API | Dashboard KPI sync |
| Google Search Console API | Dashboard SEO metrics |
| My Business Business Information API | *(optional)* GBP metrics |

---

## 2. API Keys

### Browser API Key (Maps Embed)

```
APIs & Services → Credentials → Create Credentials → API Key
```

- **Name:** Browser Key — Maps Embed
- **Application restrictions:** HTTP referrers → `yourdomain.com/*`
- **API restrictions:** Maps Embed API only
- Add to `.env`:
  ```
  GCP_API_KEY=AIzaSy...your-browser-key
  ```

### Server API Key (reCAPTCHA)

```
APIs & Services → Credentials → Create Credentials → API Key
```

- **Name:** Server Key — reCAPTCHA
- **Application restrictions:** IP addresses → your server IP
- **API restrictions:** reCAPTCHA Enterprise API only
- Add to `.env`:
  ```
  GCP_SERVER_API_KEY=AIzaSy...your-server-key
  ```

---

## 3. reCAPTCHA Enterprise v3

```
1. Go to https://console.cloud.google.com/security/recaptcha
2. Create Key → Score-based (v3)
3. Add your domain(s)
4. Copy the Site Key
```

Add to `.env`:
```
RECAPTCHA_SITE_KEY=6Le...your-site-key
```

**How it works:**
- Client-side: `grecaptcha.enterprise.execute()` gets token on form submit
- Server-side: Token validated via Assessment API with 0.5 score threshold
- Fail-open: On network error, form submission is allowed (to avoid losing leads)

---

## 4. Google Analytics 4 (GA4)

### Get your IDs

```
1. Go to https://analytics.google.com/
2. Admin → Property Settings
3. Copy Measurement ID (G-XXXXXXXXXX)
4. Copy Property ID (numeric, e.g., 123456789)
```

Add to `.env`:
```
GA4_MEASUREMENT_ID=G-XXXXXXXXXX
GA4_PROPERTY_ID=properties/123456789
```

### Data API Access

The GA4 Data API uses OAuth2 (see Step 6). Once configured, a daily cron syncs:
- Sessions, users, pageviews
- Average session duration, bounce rate
- Top 10 pages (JSON)

---

## 5. Google Search Console

### Verify Your Property

```
1. Go to https://search.google.com/search-console
2. Add Property → Domain property (recommended)
3. Verify via DNS TXT record
4. Note the property URL format
```

Add to `.env`:
```
GSC_SITE_URL=sc-domain:yourdomain.com
```

### Submit Sitemap

After your stack is running:
```
1. Go to Search Console → Sitemaps
2. Submit: https://yourdomain.com/sitemap.xml
```

### API Access

Search Console uses OAuth2 (see Step 6). Daily cron syncs:
- Clicks, impressions, CTR, average position
- Top 10 queries (JSON)
- Top 10 pages (JSON)

---

## 6. Google OAuth2 (for GA4 + Search Console APIs)

This is the most complex step. OAuth2 is used to authenticate server-side API calls.

### Create OAuth Credentials

```
1. APIs & Services → Credentials → Create Credentials → OAuth client ID
2. Application type: Web application
3. Name: "Stack Server"
4. Authorized redirect URIs: https://developers.google.com/oauthplayground
5. Copy Client ID and Client Secret
```

### Get Refresh Token

```
1. Go to https://developers.google.com/oauthplayground/
2. Click gear icon → "Use your own OAuth credentials"
3. Enter your Client ID and Client Secret
4. In Step 1, select scopes:
   - https://www.googleapis.com/auth/analytics.readonly
   - https://www.googleapis.com/auth/webmasters.readonly
   - https://www.googleapis.com/auth/business.manage (optional, for GBP)
5. Authorize APIs → Allow access
6. In Step 2: Exchange authorization code for tokens
7. Copy the Refresh Token
```

Add to `.env`:
```
GOOGLE_OAUTH_CLIENT_ID=...-apps.googleusercontent.com
GOOGLE_OAUTH_CLIENT_SECRET=GOCSPX-...
GOOGLE_OAUTH_REFRESH_TOKEN=1//...
```

**How it works:**
- WordPress plugin stores refresh token as env var
- On API call, gets access token (cached ~55 min as WP transient)
- Auto-refreshes when expired — no manual intervention needed

---

## 7. Google Business Profile (Optional)

> GBP API requires Google review and quota approval. Set up when ready.

```
1. Obtain GBP API access (requires business verification)
2. Get API Key and Account/Location IDs
```

Add to `.env`:
```
GBP_API_KEY=your-gbp-api-key
```

Until configured, the cron gracefully returns empty data.

---

## 8. Instagram Graph API (Optional)

> Not a Google service, but included in the cron sync pipeline.

```
1. Create a Facebook App at https://developers.facebook.com/
2. Add Instagram Graph API product
3. Connect your Instagram Business Account
4. Generate a long-lived access token (60 days)
```

Add to `.env`:
```
IG_ACCESS_TOKEN=your-instagram-token
IG_BUSINESS_ACCOUNT_ID=your-business-id
```

> **Note:** Instagram tokens expire every 60 days. Set a reminder to refresh.

---

## 9. Google Fonts (No Setup Required)

Google Fonts are loaded via public CDN — no API key or configuration needed.

Fonts are defined in:
- `theme/functions.php` — `wp_enqueue_style()` calls
- `theme/theme.json` — Font family definitions

To change fonts, edit those files directly.

---

## Verification Checklist

After configuring all APIs, verify with:

```bash
# Start the stack
make up

# Check container health
make status

# Tail WordPress logs for API errors
make logs-wp

# In browser: visit your dev domain
# - Contact form should show reCAPTCHA badge
# - Contact page should show Google Map
# - Admin panel should show GA4/GSC metrics after first cron run
```

### Force First Cron Sync

```bash
# Trigger the external KPI sync manually
make shell-wp
wp cron event run tma_panel_sync_external_kpis
```

---

## Environment Variables Reference

| Variable | Service | Required | Example |
|----------|---------|----------|---------|
| `GCP_API_KEY` | Maps Embed | For map | `AIzaSy...` |
| `GCP_SERVER_API_KEY` | reCAPTCHA | For forms | `AIzaSy...` |
| `RECAPTCHA_SITE_KEY` | reCAPTCHA v3 | For forms | `6Le...` |
| `GA4_MEASUREMENT_ID` | Analytics | For dashboard | `G-XXXXXXXXXX` |
| `GA4_PROPERTY_ID` | Analytics Data API | For dashboard | `properties/123456` |
| `GOOGLE_OAUTH_CLIENT_ID` | OAuth2 | For GA4+GSC | `...apps.googleusercontent.com` |
| `GOOGLE_OAUTH_CLIENT_SECRET` | OAuth2 | For GA4+GSC | `GOCSPX-...` |
| `GOOGLE_OAUTH_REFRESH_TOKEN` | OAuth2 | For GA4+GSC | `1//...` |
| `GSC_SITE_URL` | Search Console | For dashboard | `sc-domain:example.com` |
| `GBP_API_KEY` | Business Profile | Optional | API key |
| `IG_ACCESS_TOKEN` | Instagram | Optional | Long-lived token |
| `IG_BUSINESS_ACCOUNT_ID` | Instagram | Optional | Numeric ID |
