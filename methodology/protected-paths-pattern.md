# Protected Paths Pattern

Some directories must be **read-only** for the assistant — even when the spec implies a cleanup. Without explicit per-action approval, no writes, no deletes, no moves into or out of these paths.

## Why this matters

Failure mode: the assistant sees a directory that „looks unused" (old design templates, archived sprints, scraped HTML from a previous CMS) and decides to clean it up — because the active spec talks about a refactor and unused files seem like fair game.

Reality: those directories often hold the **only source of truth** for design, branding, or historical decisions. A scraped HTML folder from the predecessor CMS isn't „dead code" — it's the visual reference the rebuild is based on.

Once gone, no amount of `git revert` brings back a directory that was outside version control or that was force-removed before commit.

## Standard protected paths (adapt to your project)

| Path | Reason |
|---|---|
| `*/scrape/`, `*-scrape/` | Original-design source from external scrape (HTML/CSS/screenshots) |
| `loveable*/`, `lovable*/` | Lovable design projects with externalLovable URLs |
| `*-design/`, `design-template/` | External design templates (Figma exports, theme starters) |
| `docs/test-reports/**/snapshots/` | Before/after evidence for module refactor — frozen after creation |
| `_archive/`, `archive/` | Historical sprint archives, not for cleanup |
| `contao-scrape/`, `legacy-cms/` | Predecessor-CMS source material |

The pattern is: **anything that is the only or canonical source of an asset, decision, or external reference, and is not regenerable from running code.**

## Three-layer enforcement

1. **PreToolUse hook** (`block-destructive.sh` from `claude-code-guardrails`) — blocks `rm`, `git rm`, `git restore`, `git checkout … -- <file>`, `find -delete`, etc., on protected paths before permission logic.
2. **`.claude/settings.json` deny rules** — `Edit(protected/**)` and `Write(protected/**)` denied at permission-layer.
3. **CLAUDE.md invariant** — written list of protected paths with reasoning, so the assistant has explicit context.

The hook is the hard layer. The settings deny is belt-and-suspenders. The CLAUDE.md text is the explanation so the assistant doesn't try to bypass „because it doesn't understand why."

## Reaction when a block triggers

A blocked tool call is **a design decision, not a tool error**. Reaction pattern:

1. Explain what was attempted: „I wanted to do X, because Y."
2. Name the block reason: „protected path" / „mass-read" / „destructive command".
3. Ask the user: (a) narrow the task scope, or (b) lift the block for this specific case temporarily.

**Never bypass the block by alternative syntax** (e.g. replacing `rm -rf` with `find ... -delete`, or `ls -R` with a series of `ls` calls). That's bypass, not solution.

## Mass-Read protection (companion rule)

Same idea, different vector. These commands are blocked:

- `ls -R` over CWD
- `find .` / `find /` without filter
- `rg <pattern>` or `grep -r <pattern>` without path argument
- `cat *.md` at repo root
- `tree`, `du` without path

Reason: when the assistant „needs to understand the whole repo" before starting, the task is scoped too broadly. Solution: ask the user for narrower scope, not mass-read.

## Anti-patterns

- „I'll just delete the empty-looking folder, it's clearly unused" — without verifying it's not a design source.
- „The spec says cleanup, so cleanup is authorized" — spec is never delete-authorization. Each `rm` needs explicit user approval in the same turn.
- „I'll bypass the block because I know what I'm doing" — the block exists because past „I know what I'm doing" caused real losses.
