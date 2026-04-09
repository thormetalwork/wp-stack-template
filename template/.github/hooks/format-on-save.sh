#!/bin/bash
# Format-on-save hook — auto-formats JS/CSS files after agent edits
# Called as PostToolUse hook; receives JSON on stdin

set -euo pipefail

INPUT=$(cat /dev/stdin 2>/dev/null || echo "")

# Only trigger on file-edit tools
TOOL=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('toolName',''))" 2>/dev/null || echo "")

if ! echo "$TOOL" | grep -qiE "create_file|replace_string|edit|multi_replace"; then
  exit 0
fi

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
i = d.get('input', {})
# Try common parameter names for file path
for key in ['filePath', 'file_path', 'path']:
    if key in i:
        print(i[key])
        sys.exit(0)
# For multi_replace, get first replacement's file
replacements = i.get('replacements', [])
if replacements:
    print(replacements[0].get('filePath', ''))
    sys.exit(0)
print('')
" 2>/dev/null || echo "")

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Determine project root (where this hook lives under .github/hooks/)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Only format files in our project
if [[ "$FILE_PATH" != "$PROJECT_ROOT"/* ]]; then
  exit 0
fi

# Check file extension and format accordingly
case "$FILE_PATH" in
  *.js|*.mjs|*.css|*.json)
    # Run Prettier if available
    if command -v npx &>/dev/null && [[ -f "$PROJECT_ROOT/node_modules/.bin/prettier" ]]; then
      cd "$PROJECT_ROOT"
      npx prettier --write "$FILE_PATH" 2>/dev/null && \
        echo "{\"systemMessage\":\"✨ Auto-formatted $(basename "$FILE_PATH") with Prettier.\"}" || true
    fi
    ;;
  *.php)
    # Run PHPCBF if available
    if [[ -f "$PROJECT_ROOT/vendor/bin/phpcbf" ]]; then
      cd "$PROJECT_ROOT"
      vendor/bin/phpcbf --standard=WordPress "$FILE_PATH" 2>/dev/null && \
        echo "{\"systemMessage\":\"✨ Auto-fixed $(basename "$FILE_PATH") with PHPCBF (WordPress standards).\"}" || true
    fi
    ;;
esac

exit 0
