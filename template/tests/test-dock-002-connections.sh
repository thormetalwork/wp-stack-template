#!/bin/bash
set -e

# {{PROJECT_NAME}} — Connection Tests
# Tests MySQL queries, Redis operations, and WordPress HTTP

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PASS=0
FAIL=0

pass() { echo "  ✅ PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "🧪 Test: Service Connections"
echo "============================"

[[ -f "${PROJECT_DIR}/.env" ]] || { echo "ERROR: .env not found"; exit 1; }
source "${PROJECT_DIR}/.env"

# Test 1: MySQL can execute a query
RESULT=$(docker exec {{DOCKER_PREFIX}}_mysql bash -c "MYSQL_PWD='${MYSQL_ROOT_PASSWORD}' mysql -u root -e 'SELECT 1 AS test'" 2>/dev/null || echo "FAIL")
if echo "$RESULT" | grep -q "1"; then
    pass "MySQL executes queries"
else
    fail "MySQL cannot execute queries"
fi

# Test 2: MySQL database exists
RESULT=$(docker exec {{DOCKER_PREFIX}}_mysql bash -c "MYSQL_PWD='${MYSQL_ROOT_PASSWORD}' mysql -u root -e 'SHOW DATABASES'" 2>/dev/null || echo "")
if echo "$RESULT" | grep -q "${MYSQL_DATABASE}"; then
    pass "Database ${MYSQL_DATABASE} exists"
else
    fail "Database ${MYSQL_DATABASE} not found"
fi

# Test 3: Redis can SET/GET
docker exec {{DOCKER_PREFIX}}_redis redis-cli -a "${REDIS_PASSWORD}" --no-auth-warning SET test_key "test_value" > /dev/null 2>&1
RESULT=$(docker exec {{DOCKER_PREFIX}}_redis redis-cli -a "${REDIS_PASSWORD}" --no-auth-warning GET test_key 2>/dev/null || echo "")
if [[ "$RESULT" == "test_value" ]]; then
    pass "Redis SET/GET works"
else
    fail "Redis SET/GET failed"
fi
docker exec {{DOCKER_PREFIX}}_redis redis-cli -a "${REDIS_PASSWORD}" --no-auth-warning DEL test_key > /dev/null 2>&1

# Test 4: Redis requires authentication
RESULT=$(docker exec {{DOCKER_PREFIX}}_redis redis-cli ping 2>&1 || echo "")
if echo "$RESULT" | grep -qi "NOAUTH\|ERR"; then
    pass "Redis requires authentication"
else
    fail "Redis does not require authentication"
fi

# Test 5: MySQL port is localhost-only
RESULT=$(docker port {{DOCKER_PREFIX}}_mysql 3306 2>/dev/null || echo "none")
if echo "$RESULT" | grep -q "127.0.0.1"; then
    pass "MySQL bound to 127.0.0.1 only"
elif echo "$RESULT" | grep -q "0.0.0.0"; then
    fail "MySQL exposed on 0.0.0.0 — security risk!"
else
    pass "MySQL port not publicly mapped"
fi

echo ""
echo "Results: ${PASS} pass / ${FAIL} fail"
[[ ${FAIL} -eq 0 ]] || exit 1
