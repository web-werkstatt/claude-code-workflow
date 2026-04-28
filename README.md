# Claude Code Workflow

Methodology, rules, and templates for using [Claude Code](https://docs.claude.com/en/docs/claude-code) on real projects without the assistant silently making things worse.

> **What this is in one sentence:** A lightweight rule and template set that lets you run Claude Code on production repos with safety, reproducibility, and far less setup friction.

[Deutsche Version](./README.de.md)

---

## TL;DR

- **`rules/`** — drop-in rules for `~/.claude/rules/` that hard-limit common KI failure modes (oversized files, code duplication, path-guessing, UI-library misuse).
- **`methodology/`** — six patterns extracted from real-project use: session start/end protocols, reality-check, protected paths, write-protection policies, stop-hook pattern.
- **`templates/`** — `CLAUDE.md.template`, `.env.example`, `settings.example.json` to bootstrap a new project with these patterns in place.
- **Ready-made `CLAUDE.md` template with `${ENV}` placeholders** — fill `.env` once, generate a project-specific `CLAUDE.md` in seconds, no blank-page setup pain.
- **`docs/`** — how the layers fit together, and how this relates to the sibling repo [`claude-code-guardrails`](https://github.com/web-werkstatt/claude-code-guardrails).
- **`skills/`** — 11 curated, generic Claude Code skills (setup, session discipline, audit, secure-work).

This is **methodology + templates**. Not a tool. Not a plugin. No `npm install`.

## Scope

This repo covers **workflow and templates** for Claude Code. What you get:

- A repeatable setup you copy into every new project (CLAUDE.md, settings, rules).
- Hard limits for common LLM failure modes (file bloat, duplication, path-guessing).
- An onboarding ritual (session-start / session-end protocols) that survives across sessions.
- Templates with `${ENV}` placeholders so project-specific values stay out of the methodology.

What this **does not** cover:

- The hard destructive-op block — see [`claude-code-guardrails`](https://github.com/web-werkstatt/claude-code-guardrails).
- Project-specific deploy scripts, CI/CD, or infrastructure.
- Tech-stack-specific patterns beyond the included rules (FastAPI, Astro, etc. live in their own skill packs).

## Who is this for?

- **Solo devs** running Claude Code on multiple parallel projects, who want a consistent workflow — one mental model across many repos, not a different setup per project.
- **Small teams** reviewing KI-generated code, who want automatic hard-limits instead of manual nagging.
- **Agencies / studios** standardizing multi-project setups, who want templates instead of boilerplate.

The shared trait: you've already had Claude bloat a file to 1500 lines, hallucinate a file path, or „clean up" a directory you didn't want touched. You want that to stop.

## What problem does this solve?

| Failure mode | Without these patterns | What you get with them |
|---|---|---|
| KI keeps appending to the same file → 2000-line monolith | Manual nagging, post-hoc refactor | `rules/file-size-limits.md` enforces hard caps per file type |
| Same logic gets duplicated in 5 places | Caught in review, sometimes | `rules/code-quality-patterns.md` mandates DRY + shared helpers |
| KI invents file paths when unsure | „I'll just save it to `~/Documents/...`" | `rules/skills-before-guessing.md` requires asking |
| Spec says X, repo state is Y, KI acts on spec | Destructive corrections | `methodology/reality-check-pattern.md` mandates 3-line check first |
| Production op done (cron, SSH key) but undocumented | Lost between sessions | `methodology/session-end-protocol.md` requires explicit archive entry |
| KI „cleans up" design sources / archives | Real, irrecoverable losses | `methodology/protected-paths-pattern.md` + hook + permissions.deny |
| CLAUDE.md becomes a dump of operative + chronicle + strategy | Nobody finds anything | `methodology/write-protection-policies.md` separates by file policy |
| Empty-page setup pain on every new project | Re-write CLAUDE.md from scratch | `templates/CLAUDE.md.template` with `${ENV}` placeholders |

## What you concretely gain

- **Less production risk:** hooks, protected paths, and write-protection policies make „oops, I deleted the wrong directory" extremely unlikely.
- **Less review time:** the rules prevent 2000-line monoliths, copy-paste logic, and wild UI-library use at generation time — not after.
- **Less setup friction:** new projects start with a ready-made CLAUDE.md, a consistent workflow, and reproducible settings — not ad-hoc prompts.

In short: less risk, less time spent, less cognitive load when switching between projects.

## How to use

### Option A — adopt parts incrementally

1. Copy `rules/*.md` to `~/.claude/rules/`. Done — they're picked up by Claude on next session.
2. Read one or two methodology docs that match your current pain (start with `reality-check-pattern.md`).
3. When starting a new project, copy `templates/CLAUDE.md.template` to your project root, fill placeholders.

### Option B — full setup for a new project

1. Clone this repo.
2. Clone [`claude-code-guardrails`](https://github.com/web-werkstatt/claude-code-guardrails) for the destructive-op hook.
3. Copy `rules/*.md` → `~/.claude/rules/`.
4. Copy `claude-code-guardrails/hooks/block-destructive.sh` → `~/.claude/hooks/`.
5. In your new project:
   - Copy `templates/CLAUDE.md.template` → `CLAUDE.md`.
   - Copy `templates/.env.example` → `.env`, fill values.
   - Copy `templates/settings.example.json` → `.claude/settings.json`, adapt paths.
   - Substitute `${PLACEHOLDERS}` in `CLAUDE.md` with values from `.env` — see *Substituting `${PLACEHOLDERS}`* below.
6. Read `methodology/session-start-protocol.md` once. Internalize.

### What `.env` looks like

A minimal `.env` looks like this (full list in `templates/.env.example`):

```bash
PROJECT_NAME=my-project
PROJECT_DESCRIPTION_ONE_LINE="A short description of what this project does."
DEPLOY_SSH_HOST=my-docker-vm
DEPLOY_SCRIPT=./infrastructure/deploy/deploy.sh
DESIGN_SOURCE_DIR=design-source
TEMPLATE_DIR=design-templates
```

### Substituting `${PLACEHOLDERS}`

The `CLAUDE.md.template` uses bash-style `${VAR_NAME}` placeholders. Easiest substitution on Unix-like systems:

```bash
# After filling .env, run:
set -a && source .env && set +a
envsubst < templates/CLAUDE.md.template > CLAUDE.md
```

(`envsubst` is in the `gettext` package on most Linux distros and ships by default on macOS via Homebrew.)

For finer control or non-Unix environments (Windows without WSL, PowerShell-only setups), copy the template manually and replace placeholders by hand — or write a small replace script in PowerShell, Node.js, or Python (~10 lines).

## Repository layout

```
claude-code-workflow/
├── README.md                          # this file
├── README.de.md                       # German version
├── LICENSE                            # MIT
├── rules/                             # drop into ~/.claude/rules/
│   ├── code-quality-patterns.md
│   ├── file-size-limits.md
│   ├── skills-before-guessing.md
│   └── ui-component-libraries.md
├── methodology/                       # read once, internalize
│   ├── session-start-protocol.md
│   ├── session-end-protocol.md
│   ├── reality-check-pattern.md
│   ├── protected-paths-pattern.md
│   ├── write-protection-policies.md
│   └── stop-hook-pattern.md
├── templates/                         # bootstrap a new project
│   ├── CLAUDE.md.template
│   ├── .env.example
│   └── settings.example.json
├── docs/
│   ├── architecture.md                # how layers fit together
│   └── relationship-to-guardrails.md  # split with sibling repo
└── skills/                            # 11 curated skills + README
    ├── README.md
    ├── create-agent/                  # scaffold a subagent
    ├── create-skill/                  # scaffold a skill
    ├── setup-claude-env/              # detect stack + add LSP/rules/hooks/agents
    ├── claude-features-update/        # audit Claude Code feature usage
    ├── find-skills/                   # discover skills via npx skills
    ├── session-end/                   # archive + slim handoff + commit
    ├── dokumentenaustausch/           # shared-docs folder convention
    ├── projekt-audit-kundenplan/      # 6-phase customer project audit
    ├── owasp-security/                # OWASP Top 10 prevention patterns
    ├── accessibility-a11y/            # WCAG a11y guidelines
    └── bulletproof-container/         # container hardening + vuln scanning
```

## Relationship to `claude-code-guardrails`

The two repos are siblings:

- [`claude-code-guardrails`](https://github.com/web-werkstatt/claude-code-guardrails) — **hard layer**: PreToolUse Bash hook + `permissions.deny` patterns. Install-and-forget protection against `rm`, `git rm`, `git restore`, etc.
- **this repo** — **soft layer**: methodology, rules, templates. Process knowledge that needs internalization, not enforcement.

For most users, install both. See [`docs/relationship-to-guardrails.md`](./docs/relationship-to-guardrails.md).

## Skills (`skills/`)

11 curated, generic Claude Code skills extracted from real-project use, organized into four groups:

- **Setup & Discovery & Meta** — `create-agent`, `create-skill`, `setup-claude-env`, `claude-features-update`, `find-skills`
- **Session discipline** — `session-end`, `dokumentenaustausch`
- **Audit & customer work** — `projekt-audit-kundenplan`
- **Secure working practice** — `owasp-security`, `accessibility-a11y`, `bulletproof-container`

See [`skills/README.md`](./skills/README.md) for what each skill does and how to install. Install all with `cp -r skills/* ~/.claude/skills/` or pick selectively.

Project-specific skills (deploy scripts, customer-specific tooling, internal CMS integrations) and tech-stack-specific skills (FastAPI, Astro, Tailwind, etc.) are **not** part of this repo — those belong in private project repos or separate stack-specific skill packs.

## License

MIT — see [LICENSE](./LICENSE).

## Contributing

This is the public extract of an in-house workflow. Suggestions and corrections via issues / PRs are welcome. Project-specific patterns that don't generalize will be rejected — keep generic, keep small.

## Related work

- [`claude-code-guardrails`](https://github.com/web-werkstatt/claude-code-guardrails) — sibling repo (destructive-op block).
- [Anthropic Claude Code docs](https://docs.claude.com/en/docs/claude-code).
