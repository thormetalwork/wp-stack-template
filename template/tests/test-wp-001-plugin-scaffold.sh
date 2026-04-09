#!/bin/bash
set -e

# {{PROJECT_NAME}} — Plugin Scaffold Test
# Verifies the plugin file structure is correct

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PLUGIN_DIR="${PROJECT_DIR}/data/wordpress/wp-content/plugins/{{PLUGIN_SLUG}}"
PASS=0
FAIL=0

pass() { echo "  ✅ PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "🧪 Test: Plugin Scaffold"
echo "========================"

# Test 1: Main plugin file exists
if [[ -f "${PLUGIN_DIR}/{{PLUGIN_SLUG}}.php" ]]; then
    pass "Main plugin file exists"
else
    fail "Main plugin file {{PLUGIN_SLUG}}.php not found"
fi

# Test 2: Plugin header is valid
if grep -q "Plugin Name:" "${PLUGIN_DIR}/{{PLUGIN_SLUG}}.php" 2>/dev/null; then
    pass "Plugin header is valid"
else
    fail "Plugin header missing"
fi

# Test 3: Includes directory exists
if [[ -d "${PLUGIN_DIR}/includes" ]]; then
    pass "Includes directory exists"
else
    fail "Includes directory not found"
fi

# Test 4: Router class exists
if [[ -f "${PLUGIN_DIR}/includes/class-{{PLUGIN_SLUG}}-router.php" ]]; then
    pass "Router class file exists"
else
    fail "Router class file not found"
fi

# Test 5: API class exists
if [[ -f "${PLUGIN_DIR}/includes/class-{{PLUGIN_SLUG}}-api.php" ]]; then
    pass "API class file exists"
else
    fail "API class file not found"
fi

# Test 6: Roles class exists
if [[ -f "${PLUGIN_DIR}/includes/class-{{PLUGIN_SLUG}}-roles.php" ]]; then
    pass "Roles class file exists"
else
    fail "Roles class file not found"
fi

# Test 7: Templates directory exists
if [[ -d "${PLUGIN_DIR}/templates" ]]; then
    pass "Templates directory exists"
else
    fail "Templates directory not found"
fi

# Test 8: Security mu-plugin exists
MU_DIR="${PROJECT_DIR}/data/wordpress/wp-content/mu-plugins"
if ls "${MU_DIR}/"*-security.php 1>/dev/null 2>&1; then
    pass "Security mu-plugin exists"
else
    fail "Security mu-plugin not found"
fi

# Test 9: PHP syntax check on all plugin files
SYNTAX_ERRORS=0
while IFS= read -r -d '' file; do
    if ! php -l "$file" 2>&1 | grep -q "No syntax errors"; then
        fail "PHP syntax error in: $file"
        SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
    fi
done < <(find "${PLUGIN_DIR}" -name "*.php" -print0 2>/dev/null)
if [[ ${SYNTAX_ERRORS} -eq 0 ]]; then
    pass "All PHP files pass syntax check"
fi

echo ""
echo "Results: ${PASS} pass / ${FAIL} fail"
[[ ${FAIL} -eq 0 ]] || exit 1
