# Architecture: how the parts fit together

This repo is **methodology + templates**, not a tool. The pieces work as layers around your normal Claude Code session.

## Layer diagram

```
┌──────────────────────────────────────────────────────────────┐
│  Your project                                                │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐     │
│  │  CLAUDE.md (from templates/CLAUDE.md.template)      │     │
│  │  - source hierarchy                                 │     │
│  │  - non-negotiable invariants                        │     │
│  │  - protected paths list                             │     │
│  │  - file policies                                    │     │
│  │  - verifications                                    │     │
│  └─────────────────────────────────────────────────────┘     │
│                            ↑                                 │
│                            │ references                      │
│                            ↓                                 │
│  ┌─────────────────────────────────────────────────────┐     │
│  │  next-session.md (slim-operative)                   │     │
│  │  - NOW / NEXT / LATER                               │     │
│  │  - current operative notes                          │     │
│  └─────────────────────────────────────────────────────┘     │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐     │
│  │  next-session-archiv.md (append-top)                │     │
│  │  - sprint completions                               │     │
│  │  - production-effective ops                         │     │
│  │  - architecture decisions                           │     │
│  └─────────────────────────────────────────────────────┘     │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐     │
│  │  .claude/settings.json                              │     │
│  │  - permissions.deny for destructive ops             │     │
│  │  - protected-path Edit/Write deny                   │     │
│  │  - hooks wiring                                     │     │
│  └─────────────────────────────────────────────────────┘     │
│                                                              │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│  ~/.claude/ (user-level, shared across projects)             │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐     │
│  │  rules/*.md (from this repo's rules/)               │     │
│  │  - file-size-limits                                 │     │
│  │  - code-quality-patterns                            │     │
│  │  - skills-before-guessing                           │     │
│  │  - ui-component-libraries                           │     │
│  └─────────────────────────────────────────────────────┘     │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐     │
│  │  hooks/block-destructive.sh                         │     │
│  │  (from claude-code-guardrails repo, separate)       │     │
│  │  - blocks rm, git rm, git restore, etc.             │     │
│  └─────────────────────────────────────────────────────┘     │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐     │
│  │  CLAUDE.md (user-level, optional)                   │     │
│  │  - global rules across all projects                 │     │
│  │  - paths to protected directories                   │     │
│  │  - language preferences                             │     │
│  └─────────────────────────────────────────────────────┘     │
│                                                              │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│  Methodology (this repo's methodology/)                      │
│  Read once, internalize. Not loaded into every session.      │
│                                                              │
│  - session-start-protocol.md                                 │
│  - session-end-protocol.md                                   │
│  - reality-check-pattern.md                                  │
│  - protected-paths-pattern.md                                │
│  - write-protection-policies.md                              │
│  - stop-hook-pattern.md                                      │
└──────────────────────────────────────────────────────────────┘
```

## How a session uses these layers

1. **Session starts** → Claude reads `CLAUDE.md`, which references `next-session.md`.
2. **Reality-check** → before any task, three lines (assumption / reality / match).
3. **Edits** → file-policy-aware writes, no MANUAL block touched, GENERATED blocks overwriteable.
4. **Hard layer** → if Claude tries `rm` or touches a protected path, hook + permissions.deny block.
5. **Stop-hook** → after each response, idempotent sync script runs.
6. **Session ends** → archive entry, operative file slim, memory sync, commit clean.

## What lives where

| Concern | Lives in | Loaded when |
|---|---|---|
| Project invariants | `<project>/CLAUDE.md` | Every session |
| Operative state | `<project>/next-session.md` | Every session |
| Cross-project rules | `~/.claude/rules/*.md` | Every session (via `~/.claude/CLAUDE.md` ref) |
| Destructive-op block | `~/.claude/hooks/block-destructive.sh` | Every Bash call (PreToolUse) |
| Permission rules | `<project>/.claude/settings.json` | Every tool call |
| Methodology reference | This repo's `methodology/` | On demand |
| Templates | This repo's `templates/` | When bootstrapping a new project |

## Why this split

- **CLAUDE.md is per-project** because invariants (protected paths, deploy script, tenant model) differ.
- **Rules are user-level** because file-size limits, DRY patterns, and shadcn rules are stack-not-project specific.
- **Hooks are user-level** because the destructive-block protection should always be on.
- **Methodology is read-once** because internalization > re-reading every session.

## Relationship to claude-code-guardrails

This repo focuses on **methodology, rules, and templates**. The hard hook layer (PreToolUse Bash block, sandbox-bypass evidence, defense-in-depth pattern) lives in [claude-code-guardrails](https://github.com/web-werkstatt/claude-code-guardrails). Use both together. See [`relationship-to-guardrails.md`](./relationship-to-guardrails.md).
