# Skills

Curated, generic Claude Code skills extracted from real-project use. These complement the methodology, rules, and templates in the parent repo.

## What's in this folder

11 skills organized into four groups, all generic and project-agnostic. Project-specific skills (deploy scripts, customer-specific tooling, internal CMS integrations) are intentionally excluded.

### Setup & Discovery & Meta

| Skill | What it does |
|---|---|
| `create-agent` | Scaffolds a new Claude Code subagent with current Anthropic frontmatter conventions, minimum-permission tools, and proper system-prompt structure |
| `create-skill` | Scaffolds a new skill directory + `SKILL.md` with the current frontmatter schema (description, allowed-tools, argument-hint, etc.) |
| `setup-claude-env` | Detects an existing project's tech stack (10+ languages, frameworks, CSS, DB, infra) and adds missing LSP, rules, hooks, MCP servers, and agents — never overwrites |
| `claude-features-update` | Audits which Claude Code features (LSP, hooks, MCP, agents, plugins) the current project uses, and recommends what's missing |
| `find-skills` | Helps discover and install skills from the open agent skills ecosystem (`npx skills find …`) |

### Session-Disziplin

| Skill | What it does |
|---|---|
| `session-end` | Archives the session summary into a project-archive file, slims `next-session.md` to operative state, commits, and asks before pushing. App-Sync step (step 7) is optional and project-specific |
| `dokumentenaustausch` | Convention for a shared file-exchange folder between user and Claude (screenshots, PDFs, exports). Path is configured via `SHARED_DOCS_DIR` env var |

### Audit & Customer Work

| Skill | What it does |
|---|---|
| `projekt-audit-kundenplan` | Six-phase methodology for auditing an existing customer project against an industry checklist, producing audit reports, sprint plans, a delivery roadmap, and a customer-facing email |

### Sichere Arbeitsweise

| Skill | What it does |
|---|---|
| `owasp-security` | OWASP Top 10 (2021) prevention patterns with TypeScript code examples for all 10 categories, plus a pre-deployment security checklist |
| `accessibility-a11y` | WCAG-aligned a11y best practices: semantic HTML, ARIA, color/contrast, focus, keyboard navigation, responsive design |
| `bulletproof-container` | Container hardening + vulnerability scanning workflow (Trivy / Grype / Syft), Dockerfile templates with non-root + distroless, CI/CD integration |

## How to install

Copy the skills you want to use into your user-level Claude Code skills directory:

```bash
# All of them:
cp -r skills/* ~/.claude/skills/

# Selective:
cp -r skills/create-skill skills/session-end skills/owasp-security ~/.claude/skills/
```

Skills are picked up automatically on the next Claude Code session — no restart needed.

## Configuration

A few skills need environment variables. Set them once in `~/.bashrc` (or the equivalent shell config) or in a project-level `.env` file:

```bash
# For the dokumentenaustausch skill:
export SHARED_DOCS_DIR="$HOME/shared-docs"
```

That's it. Other skills are zero-config.

## What about project-specific skills?

This folder intentionally does **not** include skills tied to a specific project, customer, server, or stack. Examples that were excluded:

- Deploy skills with hardcoded server IPs / SSH hostnames
- Brand-specific design skills with internal logos and color palettes
- CMS-specific skills tied to a specific Payload / Directus / Ghost setup
- Stack-specific best-practice skills (FastAPI, Astro, Next.js, etc. — these belong in their own skill packs)

If you have a similar project-specific skill, keep it private — `~/.claude/skills/` (user-level) is the right place. Don't push it to the public workflow repo.

## Skill design conventions

When creating new skills, follow the conventions documented in `create-skill`:

- **`description`** front-loaded with trigger keywords (Claude matches against this for auto-invocation)
- **`allowed-tools`** granular and minimal (`Bash(git status:*)`, not `Bash(*:*)`)
- Destructive operations require explicit user confirmation in the same turn
- No emojis in skill bodies
- Reference supporting files via relative paths, don't duplicate content

## Relationship to the parent repo

These skills are the **executable layer** that complements:

- `rules/` — drop-in standards for `~/.claude/rules/`
- `methodology/` — concept patterns to internalize
- `templates/` — bootstrap files for new projects
- `skills/` — *(this folder)* runnable workflows

The methodology explains *what* to do; the skills automate *how*.
