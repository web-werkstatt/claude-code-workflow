# Relationship to `claude-code-guardrails`

This repo and [`claude-code-guardrails`](https://github.com/web-werkstatt/claude-code-guardrails) are siblings. Both address the same overarching problem — Claude Code can silently cause real, irrecoverable damage — from different angles.

## Split of concerns

| Concern | Lives in | Why |
|---|---|---|
| **Hard layer**: PreToolUse Bash hook, `permissions.deny` patterns, sandbox-bypass evidence | `claude-code-guardrails` | The block must work *before* the assistant gets a chance to reason about it. Tested, evidence-backed, narrow scope. |
| **Soft layer**: methodology, rules, templates, file policies | `claude-code-workflow` (this repo) | Process knowledge that needs internalization, not enforcement. |

## Why two repos

The decision came from observing two different audiences:

- **Audience A: „I just don't want my files deleted."**
  Wants a small, focused, install-and-forget hook. Reads the evidence doc, copies the hook, adds the deny rules, done. Doesn't want to read methodology essays.

- **Audience B: „I want to set up a real workflow for KI-assisted development."**
  Wants the bigger picture — how to structure CLAUDE.md, what file policies to use, when to do reality-check, how to end a session cleanly. Methodology and templates matter more than the hook.

Putting both in one repo would dilute both messages. The hook would get lost in methodology, and the methodology would be hidden behind installation steps.

## Recommended setup

For most users, **install both**:

1. Clone `claude-code-guardrails` → copy `block-destructive.sh` to `~/.claude/hooks/`, copy `permissions.deny` snippet to your project's `.claude/settings.json`.
2. Clone `claude-code-workflow` (this repo) → copy `rules/` to `~/.claude/rules/`, read `methodology/`, use `templates/CLAUDE.md.template` as starting point for your project.

The result: hard layer + soft layer + per-project glue.

## What overlaps (intentionally)

Both repos document protected paths and the principle „spec is never delete-authorization." That overlap is deliberate:

- `claude-code-guardrails` documents it as **why the hook exists**.
- `claude-code-workflow` documents it as **how to think about it during sessions**.

The redundancy is not a bug. The same idea needs to be present at both layers to actually stick.

## Versioning

The two repos version independently. Compatibility is loose: any version of one works with any version of the other, because they don't share code, only concepts.

## When to use only one

- **Only guardrails**: you have your own methodology and just want the destructive-op block.
- **Only workflow**: you don't want the hook (e.g. running in a fully sandboxed environment where `rm` is harmless), but you want the methodology and templates.

In practice, most users want both.
