# Reality-Check Pattern

Before starting any task that comes from a spec, sprint file, or operative document, write three lines:

1. **Assumption from spec** — what the spec says exists / should be done.
2. **Current repo reality** — verified via `ls`, `find`, `grep`, or `Read` (one targeted lookup, not a mass-scan).
3. **Match: yes / no** — and if no, stop.

## Why this matters

Specs are snapshots from the moment they were written. By the time the assistant reads them, the repo may have moved on:

- The file the spec talks about was already renamed.
- The function was already extracted.
- The bug was already fixed in another sprint.
- The migration was already applied — partially.

If the assistant trusts the spec blindly and acts on it, the action lands in a repo that doesn't match the spec's premise. Result: corrective edits that *destroy* work which had already been done.

Repo-reality wins over spec-assumptions. Always.

## Example

> Spec says: „Refactor `app/services/user_service.py` to extract `_validate_email` into shared helper."

**Without reality-check:**
- Assistant opens `app/services/user_service.py`, looks for `_validate_email`, doesn't find it (already extracted last sprint), and either:
  - Re-creates a duplicate helper (silent error).
  - Inlines validation again „because the function is missing" (active regression).

**With reality-check:**

```
Assumption from spec:    _validate_email lives in user_service.py
Current repo reality:    grep finds _validate_email only in app/utils/validation.py — already extracted
Match:                   no
→ Stop. Spec is outdated. Inform user before acting.
```

## When to apply

- Every NOW task before the first edit.
- Every claim from spec about file paths, function names, table columns, API endpoints.
- Every „remove once X" or „migrate from Y" instruction — verify both X and Y still exist as described.

## What it costs

30-60 seconds per task. Saves hours of corrective work + restores from backup.

## Anti-patterns

- „The spec was just written, surely it's accurate" — sprint specs and tasks accumulate; even fresh ones can be wrong.
- „I'll grep after I make the edit, the build will catch it" — too late if the edit is destructive (rm, mv, schema change).
- Skipping the check because „it's a small task" — small tasks are exactly where mismatch goes unnoticed.

## Connection to protected-paths

Reality-check is the soft layer. The hard layer (protected paths + destructive-bash hook) is the safety net when reality-check gets skipped. Use both.
