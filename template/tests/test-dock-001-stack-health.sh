#!/bin/bash
set -e

# {{PROJECT_NAME}} — Stack Health Test
# Tests that all Docker services are running and healthy

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PASS=0
FAIL=0

pass() { echo "  ✅ PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "🧪 Test: Stack Health"
echo "====================="

# Source .env
[[ -f "${PROJECT_DIR}/.env" ]] || { echo "ERROR: .env not found"; exit 1; }
source "${PROJECT_DIR}/.env"

# Test 1: MySQL container is running
if docker ps --format '{{.Names}}' | grep -q "{{DOCKER_PREFIX}}_mysql"; then
    pass "MySQL container is running"
else
    fail "MySQL container is not running"
fi

# Test 2: Redis container is running
if docker ps --format '{{.Names}}' | grep -q "{{DOCKER_PREFIX}}_redis"; then
    pass "Redis container is running"
else
    fail "Redis container is not running"
fi

# Test 3: WordPress container is running
if docker ps --format '{{.Names}}' | grep -q "{{DOCKER_PREFIX}}_wordpress"; then
    pass "WordPress container is running"
else
    fail "WordPress container is not running"
fi

# Test 4: phpMyAdmin container is running
if docker ps --format '{{.Names}}' | grep -q "{{DOCKER_PREFIX}}_phpmyadmin"; then
    pass "phpMyAdmin container is running"
else
    fail "phpMyAdmin container is not running"
fi

# Test 5: MySQL health check passes
if docker exec {{DOCKER_PREFIX}}_mysql bash -c "MYSQL_PWD='${MYSQL_ROOT_PASSWORD}' mysqladmin ping -u root --silent" 2>/dev/null; then
    pass "MySQL responds to ping"
else
    fail "MySQL does not respond to ping"
fi

# Test 6: Redis health check passes
if docker exec {{DOCKER_PREFIX}}_redis redis-cli -a "${REDIS_PASSWORD}" --no-auth-warning ping 2>/dev/null | grep -q "PONG"; then
    pass "Redis responds to PING"
else
    fail "Redis does not respond to PING"
fi

# Test 7: WordPress responds
if docker exec {{DOCKER_PREFIX}}_wordpress curl -sf http://localhost/wp-login.php -o /dev/null 2>/dev/null; then
    pass "WordPress responds on wp-login.php"
else
    fail "WordPress does not respond on wp-login.php"
fi

echo ""
echo "Results: ${PASS} pass / ${FAIL} fail"
[[ ${FAIL} -eq 0 ]] || exit 1
