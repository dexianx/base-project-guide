## base-project-guide

A lightweight command + skills toolkit that gives AI coding agents a structured workflow — from planning features, to writing PRDs, to committing clean code.

Works with **Claude Code**, **OpenCode**, **Cursor**, **Windsurf**, and **GitHub Copilot**.

## What's in here

| Path | What it is |
|------|------------|
| `commands/` | Slash commands / prompts: prime, plan-feature, create-prd, create-rules, execute, commit |
| `skills/` | Reusable agent skills: browser automation, E2E testing |
| `CLAUDE-template.md` | Starter template for `CLAUDE.md` / `AGENTS.md` in new projects |
| `PRD.md` | Example Product Requirements Document |

## Quickstart

### 1 — Clone

```bash
git clone https://github.com/your-username/base-project-guide.git
cd base-project-guide
```

### 2 — Install into your agent

Run the install script and follow the prompts:

```bash
chmod +x install.sh && ./install.sh
```

It auto-detects which agents you have installed and copies the right files to the right places (locally for the current project, or globally).

**Or install manually for your tool:**

| Agent | What to do |
|-------|-----------|
| **Claude Code** | Copy `.claude/commands/` into your project root (or `~/.claude/commands/` for global) |
| **OpenCode** | Copy `commands/*.md` into `.opencode/commands/` in your project |
| **Cursor** | Copy `commands/*.md` into `.cursor/rules/` (rename to `.mdc`) |
| **Windsurf** | Copy `commands/*.md` into `.windsurf/rules/` |
| **GitHub Copilot** | Append `AGENTS.md` content to `.github/copilot-instructions.md` |

### 3 — Use the commands

Once installed, trigger them from your agent:

| Command | What it does |
|---------|-------------|
| `/prime` | Loads full project context — run this first in every session |
| `/plan-feature <description>` | Deep codebase analysis → writes a complete implementation plan |
| `/create-prd [filename]` | Turns conversation context into a structured PRD |
| `/create-rules` | Generates a `CLAUDE.md` / `AGENTS.md` from your codebase |
| `/execute <plan-file>` | Implements a plan step-by-step with validation |
| `/commit` | Stages and commits all changes with a tagged message |
| `/init-project` | Runs first-time project setup (env, deps, DB, server) |

## Recommended workflow

```
/prime → understand the codebase
/create-prd → define what you're building
/plan-feature add user auth → detailed plan saved to .agents/plans/
/execute .agents/plans/add-user-auth.md → implement it
/commit → clean commit
```

## Repo notes

- **OS**: macOS-friendly (works elsewhere as long as the underlying tools do)
- **No dependencies**: pure markdown — no npm install, no build step
- **Source of truth**: `commands/` and `skills/` are canonical; all agent-specific folders are copies

## Credits

Big shout-out to **[@coleam00](https://github.com/coleam00)** for the workflow inspiration.

- **YouTube**: [https://youtu.be/goOZSXmrYQ4?si=ewxGBmlqwVrCS-pc](https://youtu.be/goOZSXmrYQ4?si=ewxGBmlqwVrCS-pc)
