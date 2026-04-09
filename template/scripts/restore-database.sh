#!/bin/bash
set -euo pipefail

# {{PROJECT_NAME}} — Database Restore
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONTAINER="{{DOCKER_PREFIX}}_mysql"
BACKUP_FILE="${1:-}"

if [[ -z "${BACKUP_FILE}" ]]; then
    echo "Usage: $0 <file.sql.gz>"
    echo "Available backups:"
    ls -lht "${PROJECT_DIR}/backups/"*.sql.gz 2>/dev/null || echo "  (none)"
    exit 1
fi

[[ -f "${PROJECT_DIR}/.env" ]] || { echo "ERROR: .env not found at ${PROJECT_DIR}/.env"; exit 1; }
source "${PROJECT_DIR}/.env"

echo "WARNING: This will overwrite the database ${MYSQL_DATABASE}"
read -p "Continue? (y/N): " confirm
if [[ "${confirm}" != "y" ]]; then
    echo "Cancelled."
    exit 0
fi

if ! gzip -t "${BACKUP_FILE}" 2>/dev/null; then
  echo "ERROR: ${BACKUP_FILE} is not a valid gzip file" >&2
  exit 1
fi

echo "Restoring from ${BACKUP_FILE}..."
gunzip -c "${BACKUP_FILE}" | docker exec -i "${CONTAINER}" bash -c "MYSQL_PWD='${MYSQL_ROOT_PASSWORD}' mysql -u root '${MYSQL_DATABASE}'"

echo "Restore completed."
