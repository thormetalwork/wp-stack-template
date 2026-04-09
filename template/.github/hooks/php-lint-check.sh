#!/usr/bin/env bash
# PostToolUse hook: Run php -l on PHP files edited via agent tools
set -e

INPUT=$(cat /dev/stdin 2>/dev/null || echo "")
TOOL=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('toolName',''))" 2>/dev/null || echo "")

if ! echo "$TOOL" | grep -qiE "edit|replace|create_file"; then
  exit 0
fi

FILE=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
i = d.get('input', {})
print(i.get('filePath', i.get('file', '')))
" 2>/dev/null || echo "")

if [[ ! "$FILE" =~ \.php$ ]]; then
  exit 0
fi

if [[ "$FILE" =~ data/wordpress/ ]]; then
  CONTAINER_PATH="${FILE#*data/wordpress/}"
  RESULT=$(docker exec {{DOCKER_PREFIX}}_wordpress php -l "/var/www/html/$CONTAINER_PATH" 2>&1 || true)
  if echo "$RESULT" | grep -qi "parse error\|fatal error"; then
    echo "{\"systemMessage\":\"⚠️ PHP Syntax Error in $CONTAINER_PATH:\\n$RESULT\"}"
  fi
elif [[ -f "$FILE" ]]; then
  RESULT=$(php -l "$FILE" 2>&1 || true)
  if echo "$RESULT" | grep -qi "parse error\|fatal error"; then
    echo "{\"systemMessage\":\"⚠️ PHP Syntax Error in $FILE:\\n$RESULT\"}"
  fi
fi
