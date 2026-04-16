# base-project-guide

This repo provides a structured set of commands and skills for AI coding agents. Use the commands below to plan, implement, and validate work systematically.

## Available Commands

Run these as slash commands (e.g. `/prime`) in Claude Code or OpenCode, or read the `.md` file directly as a prompt in any other agent.

| Command | File | What it does |
|---------|------|-------------|
| `prime` | `commands/prime.md` | Analyze the codebase and output a project overview. Run this at the start of every session. |
| `plan-feature` | `commands/plan-feature.md` | Deep codebase + external research → saves a complete implementation plan to `.agents/plans/`. Takes a feature description as argument. |
| `create-prd` | `commands/create-prd.md` | Turns conversation context into a structured Product Requirements Document. |
| `create-rules` | `commands/create-rules.md` | Analyzes codebase and generates a `CLAUDE.md` / `AGENTS.md` with project patterns and conventions. |
| `execute` | `commands/execute.md` | Reads a plan file and implements every task in order with validation. Takes plan file path as argument. |
| `commit` | `commands/commit.md` | Checks git status, stages changes, and commits with a tagged message. |
| `init-project` | `commands/init-project.md` | First-time setup: env file, deps, database, dev server. |

## Available Skills

| Skill | File | What it does |
|-------|------|-------------|
| `agent-browser` | `skills/agent-browser/SKILL.md` | Playwright-based browser automation via the `agent-browser` CLI. Navigate, interact, screenshot, record. |
| `e2e-test` | `skills/e2e-test/SKILL.md` | Full E2E testing workflow: detect frontend, start dev server, run user journeys, validate DB, report issues. |

## Recommended Workflow

```
/prime                                         # load project context
/create-prd                                    # write a PRD from the conversation
/plan-feature <what you want to build>         # research + plan → .agents/plans/*.md
/execute .agents/plans/<your-plan>.md          # implement step by step
/commit                                        # commit the result
```

## Project Layout

```
commands/          ← source of truth for all commands
skills/            ← source of truth for all skills
.claude/commands/  ← copy for Claude Code slash commands
CLAUDE-template.md ← starter template for CLAUDE.md in new projects
PRD.md             ← example Product Requirements Document
install.sh         ← installs commands into your agent of choice
```

## Notes

- All commands are plain markdown — no build step, no dependencies.
- `plan-feature` saves plans to `.agents/plans/` in the target project, not in this repo.
- `create-rules` writes to `CLAUDE.md` in the project root.
- Each command file has a YAML frontmatter `description` field for agent discoverability.
