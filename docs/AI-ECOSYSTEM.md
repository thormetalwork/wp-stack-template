# AI Ecosystem Guide

## Overview

This template includes a complete suite of AI customization files for **VS Code + GitHub Copilot Chat**. These files provide context-aware assistance tailored to your WordPress Docker stack.

## How It Works

```
User types message in Copilot Chat
        │
        ├── copilot-instructions.md loaded (always)
        │
        ├── instructions/*.instructions.md loaded (based on applyTo file patterns)
        │
        ├── agents/*.agent.md used (when @agent invoked)
        │
        ├── skills/*/SKILL.md loaded (when skill matches task)
        │
        └── prompts/*.prompt.md triggered (via /command)
```

## File Types

### `copilot-instructions.md` (1 file)
**Location**: `.github/copilot-instructions.md`

Always loaded as base context. Contains:
- Project architecture overview
- Code style conventions
- Build/test commands
- Development workflow rules
- File structure reference

### Instructions (7 files)
**Location**: `.github/instructions/`

Context-aware instruction files that auto-load based on which files you're editing.

| File | Auto-loads When Editing |
|------|------------------------|
| `docker.instructions.md` | Dockerfile, docker-compose.yml |
| `wordpress.instructions.md` | PHP files in wp-content |
| `security.instructions.md` | All files (global) |
| `scripts.instructions.md` | Files in scripts/ |
| `testing.instructions.md` | Files in tests/ |
| `env-validation.instructions.md` | .env, .env.example |
| `workflows.instructions.md` | BACKLOG.md, .github/ |

**How `applyTo` works**: The `applyTo` field in YAML frontmatter uses glob patterns. When you open Copilot Chat while editing a matching file, those instructions are automatically included.

### Agents (7 files)
**Location**: `.github/agents/`

Specialized AI personas you invoke with `@agent-name`. Each agent has:
- Focused expertise domain
- Restricted tool set
- Specific instructions for its role

| Agent | Invoke With |
|-------|------------|
| DevOps | `@devops` |
| WordPress Dev | `@wordpress-dev` |
| TDD Developer | `@tdd-developer` |
| Security Auditor | `@security-auditor` |
| Full Cycle Developer | `@full-cycle-developer` |
| Ticket Manager | `@ticket-manager` |
| Performance Analyst | `@performance-analyst` |

**Example**: `@security-auditor Check the docker-compose.yml for vulnerabilities`

### Skills (6 files)
**Location**: `.github/skills/*/SKILL.md`

Multi-step workflows that agents reference when performing complex tasks:

| Skill | What It Does |
|-------|-------------|
| `tdd-workflow` | Complete RED → GREEN → REFACTOR cycle |
| `ship-feature` | 10-phase ticket implementation (including security review) |
| `stack-management` | Docker lifecycle procedures |
| `code-review` | Structured checklist-based review |
| `ticket-management` | BACKLOG.md ticket CRUD operations |
| `wordpress-dev` | WordPress development patterns |

Skills are loaded automatically when an agent determines they're relevant to the task.

### Prompts (10 files)
**Location**: `.github/prompts/`

Quick-action slash commands in Copilot Chat:

| Command | Action |
|---------|--------|
| `/ticket` | Create a new development ticket |
| `/ship` | Implement a ticket end-to-end |
| `/tests` | Generate TDD tests |
| `/code-review` | Run structured code review |
| `/test-stack` | Health check all services |
| `/backup-database` | Create database backup |
| `/deploy` | Safe deployment |
| `/security-audit` | Full security audit |
| `/performance-check` | Performance analysis |
| `/backlog-status` | View backlog dashboard |

### Safety Hooks (1 JSON + 1 script)
**Location**: `.github/hooks/`

Pre-tool-use hooks that prevent dangerous operations:

- **Blocks**: `rm -rf /`, `docker system prune -a`, `DROP DATABASE`, `TRUNCATE`
- **Warns**: `git push --force`, `git reset --hard`
- **PHP lint**: Validates PHP syntax after every edit to a `.php` file

## Customization

### Adding a New Agent

Create `.github/agents/my-agent.agent.md`:

```yaml
---
name: my-agent
description: "Purpose of this agent"
tools: ["run_in_terminal", "read_file", "grep_search"]
---

# My Agent

You are an expert in {domain} for {{PROJECT_NAME}}.

## Rules
- Rule 1
- Rule 2

## Procedures
...
```

### Adding a New Instruction

Create `.github/instructions/my-scope.instructions.md`:

```yaml
---
description: "When to use this instruction"
applyTo: ["path/pattern/**"]
---

# My Scope Instructions

Rules and patterns for editing files in this scope.
```

### Adding a New Prompt

Create `.github/prompts/my-command.prompt.md`:

```yaml
---
description: "What this command does"
agent: "agent-name"
argument-hint: "What argument to provide"
---

# /my-command

Steps for the agent to follow...
```

### Adding a New Skill

Create `.github/skills/my-skill/SKILL.md`:

```yaml
---
name: my-skill
description: "When to use this skill"
argument-hint: "Expected input"
---

# My Skill

## When to Use
...

## Procedure
...
```
