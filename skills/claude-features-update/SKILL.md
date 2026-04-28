---
name: claude-features-update
description: Prueft und integriert die neuesten Claude Code Features in den aktuellen Projekt-Workflow. Erkennt fehlende Automatisierungen und schlaegt Verbesserungen vor. Aktiviere bei "Claude Features updaten", "neue Features", "Workflow optimieren", "Automatisierung verbessern", "was gibt es Neues".
user_invocable: true
---

# Claude Code Features Update

Prueft welche Claude Code Features im aktuellen Projekt genutzt werden
und schlaegt fehlende Automatisierungen vor.

## Schritt 1: Aktuelle Feature-Nutzung analysieren

```bash
echo "=== Claude Code Feature-Nutzung ==="

# Plugins
echo "--- Plugins ---"
python3 -c "
import json
try:
    d = json.load(open('$HOME/.claude/settings.json'))
    plugins = d.get('enabledPlugins', {})
    for p, enabled in plugins.items():
        status = 'aktiv' if enabled else 'inaktiv'
        print(f'  {p}: {status}')
except: print('  Keine settings.json')
"

# LSP Plugins
echo "--- LSP Server ---"
for cmd in pyright typescript-language-server astro-ls intelephense gopls vue-language-server svelteserver tailwindcss-language-server vscode-css-languageserver yaml-language-server docker-langserver; do
  which $cmd > /dev/null 2>&1 && echo "  $cmd: installiert" || echo "  $cmd: FEHLT"
done

# Rules
echo "--- Rules ---"
ls .claude/rules/*.md 2>/dev/null | while read f; do echo "  $(basename $f)"; done
[ ! -d .claude/rules ] && echo "  KEINE Rules konfiguriert"

# Hooks
echo "--- Hooks ---"
if [ -f .claude/hooks.json ]; then
  python3 -c "
import json
d = json.load(open('.claude/hooks.json'))
hooks = d.get('hooks', [])
print(f'  {len(hooks)} Hooks konfiguriert')
for h in hooks:
    event = h.get('matcher', {}).get('event', '?')
    name = h.get('matcher', {}).get('name', h.get('matcher', {}).get('tool_name', ''))
    print(f'    - {event}: {name}')
"
else
  echo "  KEINE Hooks konfiguriert"
fi

# MCP Server
echo "--- MCP Server ---"
if [ -f .mcp.json ]; then
  python3 -c "
import json
d = json.load(open('.mcp.json'))
for k in d.get('mcpServers', {}).keys():
    print(f'  - {k}')
"
else
  echo "  KEINE MCP Server konfiguriert"
fi

# Agenten
echo "--- Agenten ---"
ls .claude/agents/*.md 2>/dev/null | while read f; do echo "  $(basename $f .md)"; done
[ ! -d .claude/agents ] && echo "  KEINE Agenten konfiguriert"

# Memory
echo "--- Memory ---"
PROJECT_PATH=$(pwd)
MEMORY_DIR="$HOME/.claude/projects/$(echo $PROJECT_PATH | sed 's|/|-|g' | sed 's|^-||')/memory"
if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
  echo "  MEMORY.md: $(wc -l < "$MEMORY_DIR/MEMORY.md") Zeilen"
  ls "$MEMORY_DIR"/*.md 2>/dev/null | grep -v MEMORY.md | while read f; do echo "  Detail: $(basename $f)"; done
else
  echo "  KEINE Memory konfiguriert"
fi

# Skills (projektspezifisch)
echo "--- Projekt-Skills ---"
ls .claude/skills/*/SKILL.md 2>/dev/null | while read f; do
  dir=$(dirname $f)
  echo "  $(basename $dir)"
done
[ ! -d .claude/skills ] && echo "  KEINE projekt-spezifischen Skills"
```

## Schritt 2: Feature-Katalog pruefen

Folgende Claude Code Features existieren. Fuer jedes Feature pruefen ob es
im aktuellen Projekt sinnvoll waere:

### Kern-Features
| Feature | Status | Beschreibung |
|---------|--------|-------------|
| LSP | pruefen | Code-Analyse, Type-Checking, Go-to-Definition |
| Rules | pruefen | Pfad-spezifische Coding-Standards |
| Hooks | pruefen | Event-basierte Automatisierung |
| MCP Server | pruefen | Externe Service-Verbindungen |
| Agenten | pruefen | Spezialisierte Sub-Agenten |
| Memory | pruefen | Persistentes Projekt-Wissen |

### Automatisierungs-Features
| Feature | Status | Beschreibung |
|---------|--------|-------------|
| `/loop` | pruefen | Wiederkehrende Tasks (Health-Checks, Monitoring) |
| Headless Mode | pruefen | `claude -p "..."` fuer CI/CD und Cron |
| Async Hooks | pruefen | Non-blocking Hintergrund-Tasks |
| Agent Teams | pruefen | Parallele Agent-Ausfuehrung |
| Worktree Isolation | pruefen | Isolierte Agent-Umgebungen |

### Workflow-Features
| Feature | Status | Beschreibung |
|---------|--------|-------------|
| Skills (projekt) | pruefen | Wiederverwendbare Projekt-Workflows |
| Skills (global) | pruefen | Cross-Projekt Automatisierung |
| Plugins | pruefen | Gebundelte Skills + Agents + References |
| Pre-commit Hooks | pruefen | Automatische Checks vor Git Commit |
| Notification Hooks | pruefen | Desktop-Benachrichtigungen |

### Integration-Features
| Feature | Status | Beschreibung |
|---------|--------|-------------|
| Figma Plugin | pruefen | Design-to-Code (wenn UI-Projekt) |
| Stripe Plugin | pruefen | Payment-Integration (wenn E-Commerce) |
| CodeRabbit | pruefen | AI Code Review |
| Playground | pruefen | Interaktive HTML-Prototypen |
| Linear | pruefen | Issue-Tracking Integration |

## Schritt 3: Empfehlungen generieren

Basierend auf der Analyse dem User eine Tabelle mit Empfehlungen zeigen:

| Feature | Empfehlung | Grund |
|---------|-----------|-------|
| [Feature] | [Einrichten / Bereits OK / Nicht relevant] | [Warum] |

### Priorisierung
1. **Kritisch** (sofort): Fehlende LSP, fehlende Security-Rules, fehlende Secret-Detection
2. **Wichtig** (bald): Fehlende Hooks, fehlende Agenten, fehlende Memory
3. **Nice-to-have** (optional): Loop-Templates, zusaetzliche MCP Server, Plugins

## Schritt 4: Automatisch einrichten (nach User-Bestaetigung)

Fuer jedes empfohlene Feature:
1. Kurz erklaeren was es tut
2. User fragen ob es eingerichtet werden soll
3. Einrichten (via `/setup-claude-env` oder manuell)
4. Verifizieren dass es funktioniert

## Schritt 5: Neueste Features checken

Claude Code wird regelmaessig aktualisiert. Folgende Features pruefen
und integrieren wenn verfuegbar:

```bash
echo "=== Claude Code Version ==="
claude --version 2>/dev/null || echo "claude CLI nicht im PATH"

echo "=== Installierte Plugins ==="
python3 -c "
import json
try:
    d = json.load(open('$HOME/.claude/plugins/installed_plugins.json'))
    for name, entries in d.get('plugins', {}).items():
        if entries:
            v = entries[0].get('version', '?')
            updated = entries[0].get('lastUpdated', '?')[:10]
            print(f'  {name}: v{v} (updated {updated})')
except: print('  Keine plugins.json')
"
```

### Feature-Checkliste (aktualisieren wenn neue Features erscheinen)

- [ ] Extended Thinking (alwaysThinkingEnabled in settings.json)
- [ ] Agent Teams (parallele Agenten)
- [ ] Worktree Isolation (isolierte Agent-Umgebungen)
- [ ] Async Hooks (non-blocking Hintergrund-Tasks)
- [ ] Notification Hooks (Desktop-Benachrichtigungen)
- [ ] Headless Mode (claude -p fuer Automation)
- [ ] MCP Server (externe Datenquellen)
- [ ] Figma Integration (Design-to-Code)
- [ ] CodeRabbit (AI Code Review)
- [ ] Playground (interaktive Prototypen)
- [ ] Custom Keybindings (~/.claude/keybindings.json)
- [ ] Loop Automation (/loop fuer Monitoring)
- [ ] Pre-commit Hooks (Qualitaetspruefung vor Commit)
- [ ] Stop Hooks (Validierung beim Session-Ende)

## Schritt 6: Zusammenfassung

Dem User zeigen:
- Welche Features bereits genutzt werden
- Welche Features neu eingerichtet wurden
- Welche Features als naechstes sinnvoll waeren
- Naechste empfohlene Aktion
