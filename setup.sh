#!/bin/bash
set -euo pipefail

# ══════════════════════════════════════════════════════════════
# WordPress + Docker + Redis + Traefik — Stack Generator
# ══════════════════════════════════════════════════════════════
# Interactive setup script that transforms the template/ directory
# into a production-ready stack with your project configuration.
# ══════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/template"

# ── Colors ────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Helpers ───────────────────────────────────────────────────
info()    { echo -e "${BLUE}ℹ${NC}  $1"; }
success() { echo -e "${GREEN}✅${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠️${NC}  $1"; }
error()   { echo -e "${RED}❌${NC} $1" >&2; }

prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local result
    echo -en "${CYAN}${prompt}${NC} [${default}]: "
    read -r result
    echo "${result:-$default}"
}

slugify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

prefix_from_slug() {
    echo "$1" | sed 's/-/_/g' | cut -c1-3
}

generate_password() {
    openssl rand -base64 32 | tr -d '/+=' | head -c 32
}

generate_salt() {
    openssl rand -base64 64 | tr -d '/+=' | head -c 64
}

# ── Banner ────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  WordPress + Docker + Redis + Traefik Stack Generator   ║${NC}"
echo -e "${BOLD}║  Security-hardened • QA-ready • AI-assisted             ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ── Verify template exists ────────────────────────────────────
if [[ ! -d "${TEMPLATE_DIR}" ]]; then
    error "Template directory not found at ${TEMPLATE_DIR}"
    error "Are you running this from the repository root?"
    exit 1
fi

# ══════════════════════════════════════════════════════════════
# STEP 1: Collect Project Configuration
# ══════════════════════════════════════════════════════════════
echo -e "${BOLD}── Step 1: Project Configuration ──${NC}"
echo ""

PROJECT_NAME=$(prompt_with_default "Project name (human-readable)" "My Project")
PROJECT_SLUG=$(prompt_with_default "Project slug (lowercase, hyphens)" "$(slugify "$PROJECT_NAME")")
PROJECT_SLUG_UNDERSCORE=$(echo "$PROJECT_SLUG" | sed 's/-/_/g')

PREFIX_HINT=$(prefix_from_slug "$PROJECT_SLUG")
DOCKER_PREFIX=$(prompt_with_default "Docker container prefix" "${PREFIX_HINT}_dev")

PLUGIN_SLUG=$(prompt_with_default "WordPress plugin slug" "${PROJECT_SLUG}-panel")
PLUGIN_CLASS_PREFIX_HINT=$(echo "$PLUGIN_SLUG" | sed 's/-/_/g' | sed 's/\b\(.\)/\u\1/g' | sed 's/_/ /g' | sed 's/ /_/g')
PLUGIN_CLASS_PREFIX=$(prompt_with_default "PHP class prefix" "${PLUGIN_CLASS_PREFIX_HINT}")

TEXT_DOMAIN=$(prompt_with_default "WordPress text domain" "${PROJECT_SLUG_UNDERSCORE}")
TABLE_PREFIX=$(prompt_with_default "WordPress table prefix" "${PREFIX_HINT}_")

echo ""
echo -e "${BOLD}── Step 2: Domains (Traefik) ──${NC}"
echo ""

DOMAIN_BASE=$(prompt_with_default "Base domain" "${PROJECT_SLUG}.com")
DEV_DOMAIN=$(prompt_with_default "Dev site domain" "dev.${DOMAIN_BASE}")
PANEL_DOMAIN=$(prompt_with_default "Admin panel domain" "panel-dev.${DOMAIN_BASE}")
PMA_DOMAIN=$(prompt_with_default "phpMyAdmin domain" "pma-dev.${DOMAIN_BASE}")

echo ""
echo -e "${BOLD}── Step 3: Ports & Versions ──${NC}"
echo ""

MYSQL_PORT=$(prompt_with_default "MySQL local port (127.0.0.1)" "3311")
REDIS_PORT=$(prompt_with_default "Redis local port (127.0.0.1)" "6379")
PHP_VERSION=$(prompt_with_default "PHP version" "8.1")
WP_VERSION=$(prompt_with_default "WordPress version" "6.9")
MYSQL_VERSION=$(prompt_with_default "MySQL version" "8.0")
NODE_VERSION=$(prompt_with_default "Node.js version" "20")

echo ""
echo -e "${BOLD}── Step 4: Database ──${NC}"
echo ""

MYSQL_DATABASE=$(prompt_with_default "Database name" "${PROJECT_SLUG_UNDERSCORE}_wp")
MYSQL_USER=$(prompt_with_default "Database user" "${PROJECT_SLUG_UNDERSCORE}")

echo ""
echo -e "${BOLD}── Step 5: GitHub (optional) ──${NC}"
echo ""

GITHUB_ORG=$(prompt_with_default "GitHub org/user (blank to skip)" "")
GITHUB_REPO=$(prompt_with_default "GitHub repo name" "${PROJECT_SLUG}-dev")

# ══════════════════════════════════════════════════════════════
# STEP 6: Google & External APIs (optional)
# ══════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}── Step 6: Google & External APIs (optional — press Enter to skip) ──${NC}"
echo ""
info "These can be configured later in .env — see docs/GOOGLE-SETUP.md"
echo ""

GA4_MEASUREMENT_ID=$(prompt_with_default "GA4 Measurement ID (G-XXXXX)" "")
GA4_PROPERTY_ID=$(prompt_with_default "GA4 Property ID (properties/XXXXX)" "")
GCP_API_KEY=$(prompt_with_default "GCP API Key (Maps Embed — browser restricted)" "")
GCP_SERVER_API_KEY=$(prompt_with_default "GCP Server API Key (reCAPTCHA — IP restricted)" "")
RECAPTCHA_SITE_KEY=$(prompt_with_default "reCAPTCHA Enterprise v3 Site Key" "")
GOOGLE_OAUTH_CLIENT_ID=$(prompt_with_default "Google OAuth2 Client ID" "")
GOOGLE_OAUTH_CLIENT_SECRET=$(prompt_with_default "Google OAuth2 Client Secret" "")
GOOGLE_OAUTH_REFRESH_TOKEN=$(prompt_with_default "Google OAuth2 Refresh Token" "")
GSC_SITE_URL=$(prompt_with_default "Search Console site URL (sc-domain:example.com)" "")
GBP_API_KEY=$(prompt_with_default "Google Business Profile API Key" "")
IG_ACCESS_TOKEN=$(prompt_with_default "Instagram Graph API Access Token" "")
IG_BUSINESS_ACCOUNT_ID=$(prompt_with_default "Instagram Business Account ID" "")

# ══════════════════════════════════════════════════════════════
# STEP 7: Confirm Configuration
# ══════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  Configuration Summary${NC}"
echo -e "${BOLD}══════════════════════════════════════════════════════════${NC}"
echo -e "  Project:        ${GREEN}${PROJECT_NAME}${NC}"
echo -e "  Slug:           ${GREEN}${PROJECT_SLUG}${NC}"
echo -e "  Docker prefix:  ${GREEN}${DOCKER_PREFIX}${NC}"
echo -e "  Plugin:         ${GREEN}${PLUGIN_SLUG}${NC} (${PLUGIN_CLASS_PREFIX})"
echo -e "  Text domain:    ${GREEN}${TEXT_DOMAIN}${NC}"
echo -e "  Table prefix:   ${GREEN}${TABLE_PREFIX}${NC}"
echo -e "  Domains:        ${GREEN}${DEV_DOMAIN}${NC}, ${PANEL_DOMAIN}, ${PMA_DOMAIN}"
echo -e "  MySQL:          ${GREEN}127.0.0.1:${MYSQL_PORT}${NC} — ${MYSQL_DATABASE} / ${MYSQL_USER}"
echo -e "  Redis:          ${GREEN}127.0.0.1:${REDIS_PORT}${NC}"
echo -e "  Stack:          WP ${WP_VERSION} + PHP ${PHP_VERSION} + MySQL ${MYSQL_VERSION} + Redis 7"
echo -e "  Node.js:        ${GREEN}${NODE_VERSION}${NC}"
if [[ -n "$GA4_MEASUREMENT_ID" ]]; then
    echo -e "  Google APIs:    ${GREEN}Configured${NC} (GA4, OAuth, reCAPTCHA...)"
else
    echo -e "  Google APIs:    ${YELLOW}Skipped${NC} — configure later in .env"
fi
if [[ -n "$GITHUB_ORG" ]]; then
    echo -e "  GitHub:         ${GREEN}${GITHUB_ORG}/${GITHUB_REPO}${NC}"
fi
echo -e "${BOLD}══════════════════════════════════════════════════════════${NC}"
echo ""

read -p "$(echo -e "${CYAN}Proceed with this configuration? (Y/n):${NC} ")" CONFIRM
if [[ "${CONFIRM,,}" == "n" ]]; then
    echo "Cancelled. Run setup.sh again to reconfigure."
    exit 0
fi

# ══════════════════════════════════════════════════════════════
# STEP 8: Generate Project Files
# ══════════════════════════════════════════════════════════════
echo ""
info "Generating project files..."

# Copy template to project root (excluding template dir itself)
cp -r "${TEMPLATE_DIR}"/. "${SCRIPT_DIR}/"

# Rename plugin directory
if [[ -d "${SCRIPT_DIR}/data/wordpress/wp-content/plugins/{{PLUGIN_SLUG}}" ]]; then
    mv "${SCRIPT_DIR}/data/wordpress/wp-content/plugins/{{PLUGIN_SLUG}}" \
       "${SCRIPT_DIR}/data/wordpress/wp-content/plugins/${PLUGIN_SLUG}"
fi

# Rename plugin main file
if [[ -f "${SCRIPT_DIR}/data/wordpress/wp-content/plugins/${PLUGIN_SLUG}/{{PLUGIN_SLUG}}.php" ]]; then
    mv "${SCRIPT_DIR}/data/wordpress/wp-content/plugins/${PLUGIN_SLUG}/{{PLUGIN_SLUG}}.php" \
       "${SCRIPT_DIR}/data/wordpress/wp-content/plugins/${PLUGIN_SLUG}/${PLUGIN_SLUG}.php"
fi

# Rename mu-plugin security file
if [[ -f "${SCRIPT_DIR}/data/wordpress/wp-content/mu-plugins/{{PROJECT_SLUG}}-security.php" ]]; then
    mv "${SCRIPT_DIR}/data/wordpress/wp-content/mu-plugins/{{PROJECT_SLUG}}-security.php" \
       "${SCRIPT_DIR}/data/wordpress/wp-content/mu-plugins/${PROJECT_SLUG}-security.php"
fi

success "Template files copied"

# ── Replace template variables ────────────────────────────────
info "Applying template variables..."

# Build Traefik router name (slug without hyphens or short form)
TRAEFIK_ROUTER="${PREFIX_HINT}-dev"

find "${SCRIPT_DIR}" \
    -not -path "${SCRIPT_DIR}/template/*" \
    -not -path "${SCRIPT_DIR}/.git/*" \
    -not -path "${SCRIPT_DIR}/setup.sh" \
    -type f \( -name "*.yml" -o -name "*.yaml" -o -name "*.json" -o -name "*.md" \
    -o -name "*.php" -o -name "*.sh" -o -name "*.xml" -o -name "*.neon" \
    -o -name "*.mjs" -o -name "Makefile" -o -name "Dockerfile" \
    -o -name ".gitignore" -o -name ".nvmrc" -o -name ".editorconfig" \
    -o -name ".prettierrc" -o -name ".prettierignore" -o -name "pre-commit" \
    -o -name "*.txt" \) \
    -exec sed -i \
        -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
        -e "s|{{PROJECT_SLUG}}|${PROJECT_SLUG}|g" \
        -e "s|{{DOCKER_PREFIX}}|${DOCKER_PREFIX}|g" \
        -e "s|{{PLUGIN_SLUG}}|${PLUGIN_SLUG}|g" \
        -e "s|{{PLUGIN_CLASS_PREFIX}}|${PLUGIN_CLASS_PREFIX}|g" \
        -e "s|{{TEXT_DOMAIN}}|${TEXT_DOMAIN}|g" \
        -e "s|{{TABLE_PREFIX}}|${TABLE_PREFIX}|g" \
        -e "s|{{DEV_DOMAIN}}|${DEV_DOMAIN}|g" \
        -e "s|{{PANEL_DOMAIN}}|${PANEL_DOMAIN}|g" \
        -e "s|{{PMA_DOMAIN}}|${PMA_DOMAIN}|g" \
        -e "s|{{MYSQL_PORT}}|${MYSQL_PORT}|g" \
        -e "s|{{REDIS_PORT}}|${REDIS_PORT}|g" \
        -e "s|{{PHP_VERSION}}|${PHP_VERSION}|g" \
        -e "s|{{WP_VERSION}}|${WP_VERSION}|g" \
        -e "s|{{MYSQL_VERSION}}|${MYSQL_VERSION}|g" \
        -e "s|{{NODE_VERSION}}|${NODE_VERSION}|g" \
        -e "s|{{MYSQL_DATABASE}}|${MYSQL_DATABASE}|g" \
        -e "s|{{MYSQL_USER}}|${MYSQL_USER}|g" \
        -e "s|{{TRAEFIK_ROUTER}}|${TRAEFIK_ROUTER}|g" \
        {} +

success "Template variables applied"

# ══════════════════════════════════════════════════════════════
# STEP 9: Generate .env with Secure Passwords
# ══════════════════════════════════════════════════════════════
info "Generating .env with secure passwords..."

MYSQL_ROOT_PASS=$(generate_password)
MYSQL_USER_PASS=$(generate_password)
REDIS_PASS=$(generate_password)

cat > "${SCRIPT_DIR}/.env" <<ENVEOF
# ══════════════════════════════════════════════════════════════
# ${PROJECT_NAME} — Environment Variables
# ══════════════════════════════════════════════════════════════
# Generated by setup.sh on $(date +%Y-%m-%d)
# ══════════════════════════════════════════════════════════════

# ─── MySQL ───────────────────────────────────────────────────
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASS}
MYSQL_DATABASE=${MYSQL_DATABASE}
MYSQL_USER=${MYSQL_USER}
MYSQL_PASSWORD=${MYSQL_USER_PASS}

# ─── WordPress ───────────────────────────────────────────────
WORDPRESS_DB_HOST=mysql
WORDPRESS_DB_NAME=${MYSQL_DATABASE}
WORDPRESS_DB_USER=${MYSQL_USER}
WORDPRESS_DB_PASSWORD=${MYSQL_USER_PASS}
WORDPRESS_TABLE_PREFIX=${TABLE_PREFIX}

# ─── MCP Tools (VS Code Copilot) ────────────────────────────
MYSQL_MCP_HOST=127.0.0.1
MYSQL_MCP_PORT=${MYSQL_PORT}

# ─── Redis ───────────────────────────────────────────────────
REDIS_PASSWORD=${REDIS_PASS}

# ─── WordPress Debug (0=off in prod, 1=on in dev) ───────────
WORDPRESS_DEBUG=1

# ─── WordPress Salts ────────────────────────────────────────
WORDPRESS_AUTH_KEY=$(generate_salt)
WORDPRESS_SECURE_AUTH_KEY=$(generate_salt)
WORDPRESS_LOGGED_IN_KEY=$(generate_salt)
WORDPRESS_NONCE_KEY=$(generate_salt)
WORDPRESS_AUTH_SALT=$(generate_salt)
WORDPRESS_SECURE_AUTH_SALT=$(generate_salt)
WORDPRESS_LOGGED_IN_SALT=$(generate_salt)
WORDPRESS_NONCE_SALT=$(generate_salt)

# ─── phpMyAdmin BasicAuth ───────────────────────────────────
# Generate: htpasswd -nbB admin YOUR_PASSWORD (escape \$ as \$\$)
PMA_BASICAUTH_USERS=admin:\$\$apr1\$\$CHANGE_ME

# ─── Google Cloud / External APIs ───────────────────────────
GA4_MEASUREMENT_ID=${GA4_MEASUREMENT_ID:-}
GA4_PROPERTY_ID=${GA4_PROPERTY_ID:-}
GCP_API_KEY=${GCP_API_KEY:-}
GCP_SERVER_API_KEY=${GCP_SERVER_API_KEY:-}
RECAPTCHA_SITE_KEY=${RECAPTCHA_SITE_KEY:-}
GOOGLE_OAUTH_CLIENT_ID=${GOOGLE_OAUTH_CLIENT_ID:-}
GOOGLE_OAUTH_CLIENT_SECRET=${GOOGLE_OAUTH_CLIENT_SECRET:-}
GOOGLE_OAUTH_REFRESH_TOKEN=${GOOGLE_OAUTH_REFRESH_TOKEN:-}
GSC_SITE_URL=${GSC_SITE_URL:-}
GBP_API_KEY=${GBP_API_KEY:-}
IG_ACCESS_TOKEN=${IG_ACCESS_TOKEN:-}
IG_BUSINESS_ACCOUNT_ID=${IG_BUSINESS_ACCOUNT_ID:-}
ENVEOF

success ".env generated with secure passwords and salts"
warn "Update PMA_BASICAUTH_USERS with a real htpasswd hash"

# ══════════════════════════════════════════════════════════════
# STEP 10: Initialize Git Repository
# ══════════════════════════════════════════════════════════════
info "Initializing Git repository..."

cd "${SCRIPT_DIR}"
git init -b main
git add -A
git commit -m "feat: Initialize ${PROJECT_NAME} stack from wp-stack-template

Stack: WordPress ${WP_VERSION} + PHP ${PHP_VERSION} + MySQL ${MYSQL_VERSION} + Redis 7
Generated by: https://github.com/thormetalwork/wp-stack-template"

success "Git repository initialized with first commit"

# ══════════════════════════════════════════════════════════════
# STEP 11: Create GitHub Repository (optional)
# ══════════════════════════════════════════════════════════════
if [[ -n "$GITHUB_ORG" ]]; then
    info "Creating GitHub repository..."
    if command -v gh &>/dev/null; then
        gh repo create "${GITHUB_ORG}/${GITHUB_REPO}" --private \
            --description "${PROJECT_NAME} — WordPress + Docker + Redis + Traefik stack" \
            --source . --push 2>&1 || warn "GitHub repo creation failed. Create manually and push."
        success "GitHub repository created and code pushed"
    else
        warn "GitHub CLI (gh) not installed. Create repo manually:"
        echo "  gh repo create ${GITHUB_ORG}/${GITHUB_REPO} --private --source . --push"
    fi
fi

# ══════════════════════════════════════════════════════════════
# STEP 12: Cleanup
# ══════════════════════════════════════════════════════════════
info "Cleaning up template files..."

rm -rf "${SCRIPT_DIR}/template"
rm -f "${SCRIPT_DIR}/setup.sh"
rm -f "${SCRIPT_DIR}/LICENSE"

git add -A
git commit -m "chore: Remove template scaffolding" --allow-empty

success "Template files removed"

# ══════════════════════════════════════════════════════════════
# DONE
# ══════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  ${GREEN}✅ ${PROJECT_NAME} stack is ready!${NC}${BOLD}                       ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Quick Start:${NC}"
echo -e "  ${CYAN}1.${NC} Review .env and update PMA_BASICAUTH_USERS"
echo -e "  ${CYAN}2.${NC} Configure Google APIs in .env (see docs/GOOGLE-SETUP.md)"
echo -e "  ${CYAN}3.${NC} Ensure Traefik is running with traefik-public network"
echo -e "  ${CYAN}4.${NC} make up          — Start the stack"
echo -e "  ${CYAN}5.${NC} make test        — Verify all connections"
echo -e "  ${CYAN}6.${NC} make status      — Check container health"
echo ""
echo -e "  ${BOLD}Development:${NC}"
echo -e "  ${CYAN}•${NC} make lint        — Run all linters"
echo -e "  ${CYAN}•${NC} make test-all    — Run all test suites"
echo -e "  ${CYAN}•${NC} make backup      — Backup database"
echo -e "  ${CYAN}•${NC} make logs        — Tail all logs"
echo ""
echo -e "  ${BOLD}Documentation:${NC}"
echo -e "  ${CYAN}•${NC} README.md              — Project overview"
echo -e "  ${CYAN}•${NC} docs/GOOGLE-SETUP.md   — Google API configuration guide"
echo -e "  ${CYAN}•${NC} docs/                  — Architecture, security, AI ecosystem"
echo ""
