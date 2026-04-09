---
description: "Use when writing or running tests: bash test scripts, TDD patterns, assertions, test structure."
applyTo: ["tests/**", "**/test-*"]
---
# Testing Instructions — {{PROJECT_NAME}}

## Test Naming Convention
- Bash: `tests/test-{scope}-{num}-{description}.sh`

## Test Structure (AAA Pattern)
```
Arrange → Setup context and input data
Act     → Execute the function/method under test
Assert  → Verify the expected result
```

## Standard Test Template
```bash
#!/bin/bash
set -e
PASS=0
FAIL=0

pass() { echo "  ✅ PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "🧪 Test: {description}"
echo "========================"

# ... tests with pass/fail counters

echo ""
echo "Results: ${PASS} pass / ${FAIL} fail"
[[ ${FAIL} -eq 0 ]] || exit 1
```

## TDD Cycle Enforcement
1. Write test FIRST → Must FAIL (RED)
2. Implement minimum code → Must PASS (GREEN)
3. Refactor → Must still PASS (REFACTOR)
4. NEVER commit implementation without corresponding tests

## Coverage Target
- New features: minimum 80% coverage
- Bug fixes: 100% coverage for the bug scenario (regression test)
