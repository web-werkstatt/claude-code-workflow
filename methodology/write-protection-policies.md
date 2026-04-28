# Write-Protection Policies

Manually written text is protected. The assistant must not silently shorten, rephrase, „clean up", or summarize human-written content unless explicitly instructed.

## Core rule

- Existing manually written text is **not** to be shortened, rephrased, or summarized without instruction.
- Unmarked text counts as **manual-protected** by default.
- Only clearly marked **GENERATED blocks** may be selectively overwritten.
- When write-permission is unclear: append, don't rewrite.

## File policy types

| Policy | Meaning |
|---|---|
| `slim-operative` | Current operative state only. No history. Overwriteable when state changes. |
| `append-top` | Newest entries at the top. Existing entries must not be edited or removed. |
| `append-only` | New entries appended (top or bottom defined per file). Existing entries frozen after creation. |
| `overwriteable-snapshot` | Whole-file replacement allowed when content represents a snapshot (overview tables, master plans). |
| `read-only-after-creation` | Once written, frozen. Used for evidence files (before/after snapshots, audit reports). |
| `generated-blocks-only` | Mixed file. MANUAL blocks frozen, GENERATED blocks selectively overwriteable. |
| `read-only` | Never written by assistant. Source-of-truth files (design scrapes, archives). |

## Marker convention for `generated-blocks-only` files

```md
<!-- MANUAL:START owner=<name> -->
...manually written, protected content...
<!-- MANUAL:END -->

<!-- GENERATED:START source=claude updated=YYYY-MM-DD -->
...selectively overwriteable generated content...
<!-- GENERATED:END -->
```

The assistant may rewrite GENERATED blocks (replacing with new generated content of the same intent). MANUAL blocks are off-limits without explicit user instruction.

## Suggested file-policy table for a project

| File / directory | Policy | Notes |
|---|---|---|
| `next-session.md` (or operative file) | `slim-operative` | NOW / NEXT / LATER + operative notes. No sprint chronicle. |
| `next-session-archiv.md` | `append-top` | Sprint completions, architecture decisions. Newest on top. |
| `next-session-history.md` | `append-top` | Session log. |
| `sessions/sprints/*.md` (after creation) | `append-only` | Don't rewrite spec, only extend or update status. |
| `docs/test-reports/**/snapshots/` | `read-only-after-creation` | Before/after evidence. |
| `CLAUDE.md`, similar root-doc | `generated-blocks-only` | Mix of manual policy + generated overview. |
| `docs/audit/*.md` | `read-only` after sign-off | Audit findings. |
| `_archive/**`, `archive/**` | `read-only` | Historical archives. |

Adapt to your project. The pattern matters more than the exact filenames.

## Why this matters

Without a policy, the assistant tends to:

- Rewrite manually written sections in „cleaner" English without asking.
- Compress historical entries („consolidating older notes") and lose context.
- Overwrite operative files with generated overviews, mixing state with chronicle.
- Touch files that the user considers frozen (audit reports, design specs).

A written policy table makes the rules legible and enforceable.

## Operational tips

- **For each `Write` / `Edit` call, the assistant should mentally check:** „what's the policy of this file?"
- If the policy is `read-only-after-creation` or `read-only`, refuse the write and ask.
- If the policy is `append-top` and the assistant is asked to „update", default to appending, not editing existing entries.
- Policy markers (in CLAUDE.md or a dedicated `WRITE-POLICY.md`) should be visible to the assistant on every session start.

## Anti-patterns

- „I'll improve the wording while I'm in there" — pure rewriting of manual prose without explicit instruction.
- „I'll deduplicate similar archive entries" — destroys timestamped history.
- „I'll merge the two operative files since they overlap" — destroys the operative/history distinction.
- Editing inside a MANUAL block to „extend" what the user wrote.
