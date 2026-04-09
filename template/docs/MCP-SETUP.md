# MCP Server Setup Guide

> Model Context Protocol (MCP) servers give GitHub Copilot direct access to your databases, cache, git history, and browser — enabling AI-assisted operations without leaving VS Code.

## Overview

Your project includes **5 pre-configured MCP servers** in `.vscode/mcp.json`:

| Server | Transport | Package | Purpose |
|--------|-----------|---------|---------|
| **GitHub** | HTTP | Built-in (Copilot) | Repository, issues, PRs |
| **Playwright** | Stdio | `@playwright/mcp@latest` | Browser automation, screenshots |
| **Redis** | Stdio | `redis-mcp-server@latest` | Cache operations (GET, SET, SCAN, etc.) |
| **MySQL** | Stdio | `@benborla29/mcp-server-mysql` | SQL queries (SELECT, INSERT, UPDATE, DDL) |
| **Git** | Stdio | `mcp-server-git` | Log, diff, blame, branch history |

## How It Works

MCP servers are configured in `.vscode/mcp.json` and loaded automatically by VS Code when GitHub Copilot is active. Each server runs as a subprocess (stdio) or connects via HTTP.

**Important:** VS Code does NOT expand shell environment variables (`${VAR}`) in `mcp.json`. All credentials must be **literal values**. This is why `setup.sh` generates `mcp.json` with actual passwords instead of variable references.

## File Locations

| File | Purpose | Git-tracked |
|------|---------|-------------|
| `.vscode/mcp.json` | MCP server configuration (credentials) | ❌ No (gitignored) |
| `.vscode/settings.json` | Editor settings | ✅ Yes |
| `.vscode/extensions.json` | Recommended extensions | ✅ Yes |
| `.github/hooks/sql-guard.sh` | SQL safety hook for MCP MySQL | ✅ Yes |

## Server Details

### 1. GitHub (HTTP)

```json
{
  "type": "http",
  "url": "https://api.githubcopilot.com/mcp"
}
```

- **No configuration needed** — authenticates via Copilot session
- Enables: repo search, issue creation, PR reviews, file browsing
- Works in any workspace with Copilot active

### 2. Playwright (Stdio)

```json
{
  "command": "npx",
  "args": ["-y", "@playwright/mcp@latest", "--headless"]
}
```

- **Requires:** Node.js (npx)
- Enables: navigate pages, click elements, take screenshots, fill forms
- Runs headless by default — remove `--headless` for visible browser
- Auto-installs on first use via npx

### 3. Redis (Stdio)

```json
{
  "type": "stdio",
  "command": "uvx",
  "args": [
    "-qq",
    "--from", "redis-mcp-server@latest",
    "redis-mcp-server",
    "--url", "redis://:YOUR_REDIS_PASSWORD@localhost:6379/0"
  ]
}
```

- **Requires:** Python (`uvx` from uv package manager)
- Enables: GET, SET, DEL, HGETALL, SCAN, PUBLISH, key inspection
- Connects to Redis container via localhost port mapping
- **Credential:** Redis password embedded in URL

### 4. MySQL (Stdio)

```json
{
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@benborla29/mcp-server-mysql"],
  "env": {
    "MYSQL_HOST": "127.0.0.1",
    "MYSQL_PORT": "3311",
    "MYSQL_USER": "your_user",
    "MYSQL_PASS": "your_password",
    "MYSQL_DB": "your_database",
    "ALLOW_INSERT_OPERATION": "true",
    "ALLOW_UPDATE_OPERATION": "true",
    "ALLOW_DELETE_OPERATION": "true",
    "ALLOW_DDL_OPERATION": "true"
  }
}
```

- **Requires:** Node.js (npx)
- Enables: SELECT, INSERT, UPDATE, DELETE, DDL (CREATE/ALTER/DROP)
- Connects via localhost port mapping (Docker exposes MySQL on configured port)
- **Security:** The `sql-guard.sh` hook blocks destructive operations (DROP, TRUNCATE, DELETE without WHERE)

#### Restricting MySQL Operations

To make MySQL read-only, set write flags to `"false"`:

```json
"ALLOW_INSERT_OPERATION": "false",
"ALLOW_UPDATE_OPERATION": "false",
"ALLOW_DELETE_OPERATION": "false",
"ALLOW_DDL_OPERATION": "false"
```

### 5. Git (Stdio)

```json
{
  "type": "stdio",
  "command": "uvx",
  "args": ["mcp-server-git"]
}
```

- **Requires:** Python (`uvx` from uv package manager)
- Enables: git log, diff, blame, show, branch listing
- No credentials needed — uses local git repository
- Works in any directory with a `.git` folder

## Prerequisites

| Tool | Required By | Install |
|------|-------------|---------|
| Node.js | Playwright, MySQL | `nvm install 20` or `apt install nodejs` |
| Python + uv | Redis, Git | `pip install uv` or `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Docker | Redis, MySQL (containers) | Stack must be running (`make up`) |

## Updating Credentials

If you change database or Redis passwords in `.env`, you must **also update `.vscode/mcp.json`** manually:

```bash
# 1. Update .env with new password
# 2. Edit .vscode/mcp.json — replace old password with new one
# 3. Restart VS Code to reload MCP servers
```

There is no automatic sync between `.env` and `mcp.json` because VS Code cannot resolve environment variables.

## Adding New MCP Servers

To add a custom MCP server, edit `.vscode/mcp.json`:

```json
{
  "servers": {
    "existing-servers": "...",
    "my-new-server": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "my-mcp-package"],
      "env": {
        "API_KEY": "literal-value-here"
      }
    }
  }
}
```

### Popular MCP Servers

| Server | Package | Purpose |
|--------|---------|---------|
| **Filesystem** | `@anthropic-ai/mcp-filesystem` | Read/write local files |
| **PostgreSQL** | `@anthropic-ai/mcp-postgres` | PostgreSQL queries |
| **Slack** | `@anthropic-ai/mcp-slack` | Channel messages, threads |
| **Linear** | `mcp-linear` | Issue tracking integration |

## Troubleshooting

### MCP server not connecting

1. **Check Docker is running:** `make status` — Redis and MySQL containers must be healthy
2. **Verify ports:** `ss -tlnp | grep 3311` (MySQL) and `ss -tlnp | grep 6379` (Redis)
3. **Check credentials:** Compare `.env` passwords with `.vscode/mcp.json` values
4. **Restart VS Code:** MCP servers are loaded on startup — changes require reload

### "Variable not resolved" errors

VS Code does **not** expand `${VAR}` in `mcp.json`. Replace with literal values:

```json
// ❌ Does NOT work
"--url", "redis://:${REDIS_PASSWORD}@localhost:6379/0"

// ✅ Works — use literal value
"--url", "redis://:actualPassword123@localhost:6379/0"
```

### uvx/npx not found

```bash
# Install uv (for uvx)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Verify
which uvx   # → ~/.local/bin/uvx
which npx   # → should exist with Node.js
```
