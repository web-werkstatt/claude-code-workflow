# Stop-Hook Pattern

A Stop-hook fires after every assistant response. Use it to keep cross-source data in sync automatically — no manual reminder needed.

## When this is useful

Many projects have **two or more places** that hold the same fact:

- A status table in `INDEX.md` and individual status fields in per-item files.
- A backlog file and a per-task spec.
- A signoff JSON and a status column in markdown.

If the assistant updates one and forgets the other, they drift. A Stop-hook closes that gap.

## What the hook does

After every assistant response:

1. **Run a sync script** that propagates a designated source-of-truth into derived locations.
   - Example: `freigaben.json` → status columns in `d*.md` files, idempotent.
2. **Check for pending state** that wasn't synced — log a reminder for the next response.
3. **Optional: trigger a known slash-command** if drift is detected (e.g. `/dashboard-update`).

## Loop protection

A Stop-hook can technically trigger itself indefinitely. The Claude Code hook spec provides a `stop_hook_active` flag — when true, the hook should detect this and exit early to break the loop.

```bash
#!/bin/bash
# Example pattern — adapt to your actual hook input format
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

# Your sync script here
python apply_sync.py --idempotent

# Optional: log reminder for pending items
if grep -q "pending" status.json; then
  echo "Reminder: pending entries — consider running /sync-command" >> stop-hook.log
fi
```

## Idempotency is critical

The sync script **must** be idempotent. It runs after every response, often dozens of times per session. If running it twice produces a different result than running it once, you have drift bugs and possibly data loss.

Test pattern:

```bash
python apply_sync.py
md5sum derived-files/*.md > before.md5
python apply_sync.py
md5sum derived-files/*.md > after.md5
diff before.md5 after.md5  # must be empty
```

## What NOT to put in a Stop-hook

- **Slow operations** (> ~2s) — every response gets delayed.
- **Network calls** to external services — fragile, blocks responses on outage.
- **Anything that can fail without recovery path** — failed hook can block session.
- **Anything that writes to operative files** — risk of overwriting user-meant content. Stick to derived/generated content.

## Example use cases

| Use case | Source | Sync target | Idempotent? |
|---|---|---|---|
| Audit signoff sync | `signoffs.json` | Status column in `audit/*.md` | yes — overwrite specific column |
| Sprint progress | Sprint file frontmatter | `INDEX.md` table row | yes — replace row by sprint-id key |
| Memory pointer index | `memory/*.md` files | `MEMORY.md` index | yes — regenerate from filenames |
| Linkage check | All sprint files | `MASTER_PLAN.md` linkage section | yes — regenerate from glob |

## Connection to other patterns

- **Write-protection policies**: the hook only writes to files marked `overwriteable-snapshot` or specific GENERATED blocks. Never to MANUAL content.
- **Reality-check**: the hook itself is part of reality-check infrastructure — it ensures derived state matches source-of-truth automatically.
- **Session-end protocol**: the hook keeps things in sync between sessions. The session-end protocol catches what the hook can't (cron, SSH keys, etc.).

## Anti-patterns

- Hooks that write to manual content.
- Non-idempotent hooks.
- Hooks that fail silently — at minimum, log to a known location.
- Multiple Stop-hooks doing overlapping work.
