---
description: "Use when editing any development workflow: tickets, branches, commits, PRs, testing, deployment."
applyTo: ["BACKLOG.md", ".github/**"]
---
# Development Workflow — {{PROJECT_NAME}}

## Branch Strategy
```
main          ← Stable production (protected, requires PR + green CI)
  └── dev     ← Active development (protected, requires PR)
       └── feat/TICKET-XXX-description  ← Features (merge → dev via PR)
       └── fix/TICKET-XXX-description   ← Bug fixes (merge → dev via PR)
       └── hotfix/TICKET-XXX-description ← Urgent production fix (merge → main via PR)
```

## Commit Convention
```
{type}(TICKET-{SCOPE}-{NUM}): Brief description

Types: feat, fix, refactor, docs, test, style, chore, perf
```

## Continuous Flow per Ticket
```
1. 📋 Create ticket in BACKLOG.md
2. 🌿 Create branch from dev
3. 🔴 RED: Write failing tests
4. 🟢 GREEN: Implement minimum code to pass tests
5. 🔵 REFACTOR: Improve while keeping tests green
6. 📝 Commit: feat(TICKET-XXX): Description
7. 🚀 Push + PR → dev
8. 🔍 Code Review + CI
9. ✅ Merge (squash) + close ticket in BACKLOG.md
```

## Quality Gates (before merge to dev)
- [ ] Tests pass: `make test-all`
- [ ] Lint clean: `make lint`
- [ ] Format verified: `make lint-format`
- [ ] Backup created (if DB/Docker changes)
- [ ] Code review completed
- [ ] Acceptance criteria verified
