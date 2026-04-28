# Session-End Protocol

Every session that changes code, production setup, or workflow configuration **must** execute these steps before ending:

1. **Append entry to session archive** (newest first) with:
   - Completed sprints / tasks (sprint file reference + brief description of impact)
   - **Production-effective operations** (containers, cron jobs, SSH keys, storage setups) — explicitly, because the repo alone doesn't show this
   - **Discovered bugs / follow-up tasks** with effort estimate
   - **Deliberately deferred tasks** with reasoning
   - Commit hashes + tags of the session

2. **Update operative file** (`next-session.md` or equivalent) — bring NOW/NEXT/LATER up to date, remove completed items, add new follow-ups.

3. **Update memory** if new patterns, setups, or rules emerged.

4. **Verify last commit + tag** — are all changes pushed? `git status` clean (or deliberately dirty with reasoning in archive)?

## Why this matters

Production-effective operations don't show up in `git log` as such — installing a cron job, adding an SSH key, or configuring a backup repo leaves the repo unchanged but changes the production system. Without an explicit archive entry, that knowledge disappears between sessions.

For small sessions (pure doc edits without production impact): the archive entry can be a one-liner, but should not be skipped.

## File policies for archive vs. operative

- **Operative file** (`next-session.md`): slim, current state only. No history.
- **Archive file** (`next-session-archiv.md`): append-top, never overwritten. Sprint completions, decisions, production ops.
- **History file** (`next-session-history.md`, optional): full session log, append-top.

## Trigger phrases

The user typically signals session end with phrases like:

- „Session beenden"
- „für morgen"
- „Feierabend"
- „Session zusammenfassen"
- „was haben wir gemacht"

A skill can be wired to these triggers to automate the protocol (archive update → operative slim → memory sync → commit prompt).

## Anti-patterns

- Ending a session with `git status` showing uncommitted changes and no explanation.
- Writing the archive entry into `next-session.md` (mixing operative state with history).
- Forgetting to record production-effective operations (cron, SSH keys, storage setups).
- Skipping memory sync when a new reusable pattern emerged.
