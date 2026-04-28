# Session-Start Protocol

When starting a new task, follow this reading order before touching code:

1. **Operative status file** (e.g. `next-session.md`) — current NOW / NEXT / LATER tasks and operational notes.
2. **Master plan / sprint overview** — the document defining tracks, workflow conventions, and module inventory.
3. **Active sprint file** — the sprint currently in progress, with its definition-of-done.
4. **Audit / findings reference** — kept at hand, not read in full unless needed.
5. **Project CLAUDE.md** — for invariants and protected paths.

If sources contradict each other, the **most recent operative file** wins over older chronicles or archives.

At the beginning of each session, briefly state:

- Which files you read.
- Which one is leading for the current task.
- The current NOW task verbatim.
- Confirmation that you understand the non-negotiable invariants.

## Why this matters

Without a fixed reading order, the assistant tends to:

- Pull stale information from archived docs.
- Miss the active sprint's definition-of-done.
- Re-derive context from code instead of reading the spec.
- Skip the protected-paths list.

A 30-second reading protocol at session start saves 30 minutes of correction later.

## Source hierarchy (binding)

| Priority | Source | Type |
|---|---|---|
| 1 | `next-session.md` | Operative steering |
| 2 | Master plan | Workflow conventions |
| 3 | Active sprint file | Definition-of-done |
| 4 | Sprint index | Overview |
| 5 | Audit / findings doc | Reference |
| 6 | Engineering standards | Code rules |
| 7 | Operational commands doc | Container / DB / deploy |
| 8 | Historical archives | Only on demand |

## Anti-patterns

- Reading every `*.md` at repo root before starting work — wastes context, often blocked by mass-read guardrail.
- Inferring task scope from `git log` alone — misses the spec's intent.
- Skipping the operative file because „it was just updated" — that's exactly when to read it.
