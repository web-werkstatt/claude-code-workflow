---
name: create-agent
description: Use when the user says "/create-agent [name]", "neuen Agent erstellen", "create agent", or asks to scaffold a new Claude Code subagent. Creates an agent definition file in `.claude/agents/<name>.md` following current Anthropic best practices (Opus 4.7 / 2026), including frontmatter schema and minimum-permission tools.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(ls:*), Bash(mkdir:*), Bash(git status:*), Bash(git add:*), Bash(git diff:*)
argument-hint: [agent-name] [optional purpose]
---

# Agent erstellen

Erstellt eine neue Claude Code Subagent-Definition mit aktueller
Anthropic-Konvention. Subagents liegen als einzelne Markdown-Datei in
`.claude/agents/<name>.md` (global oder projekt-lokal) und koennen vom
Hauptagenten per `Agent({ subagent_type: "<name>" ... })` delegiert
werden.

## Unterschied zu Skills

- **Skill:** wird per Trigger-Phrase oder `/command` aktiviert, arbeitet
  im Haupt-Conversation-Scope, liefert Anleitung an Claude.
- **Agent/Subagent:** separater ausfuehrender Kontext, wird explizit per
  `Agent`-Tool aufgerufen, oft mit eigenem System-Prompt, eigenen Tools
  und eigenem Modell. Gut fuer Parallelarbeit und Kontext-Isolation.

## Argumente

- **name** — kebab-case, eindeutig (z.B. `ssl-manager`)
- **purpose** — 1 Satz, was der Agent autonom erledigen soll
- **scope** — global (`~/.claude/agents/`) oder projekt-lokal
  (`<project>/.claude/agents/`)
- **allowed-tools** — Minimum-Set, nur was der Agent wirklich braucht
- **model** — optional; wenn der Agent ein anderes Modell als die
  Session verwenden soll (z.B. Haiku fuer schnelle Recherche)

## Verzeichnisstruktur

```
<scope>/agents/<name>.md
```

Agent-Definitionen sind **einzelne .md-Dateien**, keine Verzeichnisse.
Wenn Hilfs-Skripte oder Referenzen noetig sind, liegen sie daneben
oder werden im Agent-Body verlinkt.

## Frontmatter-Schema

```yaml
---
name: <kebab-case>                       # optional — default ist Dateiname
description: <Wann Agent einsetzen, 1-2 Saetze>
model: claude-haiku-4-5-20251001         # optional — default ist Session-Modell
tools: Read, Grep, Glob, Bash(git log:*) # optional — Minimum-Tool-Set
color: cyan                              # optional — UI-Akzentfarbe
---
```

Nur setzen, was gebraucht wird. `description` ist wichtig fuer
Auto-Delegation: der Hauptagent matcht die Aufgabenbeschreibung gegen
`description`, um zu entscheiden, welcher Subagent geeignet ist.

## description-Heuristik

Gut (klar abgegrenzter Zweck + Positiv-/Negativbeispiele):

```yaml
description: Use this agent to investigate build failures. Reads CI logs, git diff, and recent commits; produces a short root-cause report. Do NOT use for runtime bugs in production — use the log-debug agent for that.
```

Weniger gut:

```yaml
description: Helps with stuff.
```

## Agent-Body-Template

Der Body ist der **System-Prompt** des Subagents. Er laeuft in
isoliertem Kontext, sieht NICHT die aktuelle Conversation. Alles, was
er wissen muss, muss im Body stehen.

```markdown
---
name: <name>
description: Use this agent to <konkreter Zweck>. <Grenzen/Negativfall>.
model: <optional>
tools: Read, Grep, Bash(<subcmd>:*)
---

# <Agent-Titel>

Du bist ein spezialisierter Subagent fuer <Aufgabe>.

## Dein Auftrag

<1-2 Saetze: was du tust, was du nicht tust.>

## Kontext, den du selbst holen musst

- Repo-Layout: siehe `CLAUDE.md` im Arbeitsverzeichnis
- Konventionen: <welche Dateien sind fuehrend>
- Abhaengigkeiten: <z.B. API-Endpoints, Service-URLs, Pfade>

## Arbeitsweise

### 1. <Phase 1 — Analyse/Sammlung>

- <Konkrete Befehle>
- <Was du lesen sollst>

### 2. <Phase 2 — Aktion>

- <Was du schreibst/aenderst>
- <Wie du Rueckfragen vermeidest, wo moeglich>

### 3. <Phase 3 — Abschluss>

- <Strukturierter Report zurueck an den Hauptagenten>
- <Keine Smalltalk, keine Wiederholung der Aufgabe>

## Report-Format

Antworte dem Hauptagenten in dieser Struktur:

```
Findings:
- ...

Actions:
- ...

Open questions / needs approval:
- ...
```

## Destruktive Aktionen

- Kein automatisches Git-Push.
- Kein `rm -rf`, kein `docker rm -f` ohne expliziten Auftrag im Prompt.
- Bei Unsicherheit: melden, nicht handeln.

## Grenzen

- <Wofuer der Agent nicht zustaendig ist>
- <Wann der Hauptagent es selbst machen sollte>
```

## Workflow

1. Agent-Name validieren (kebab-case, kein Duplikat):
   ```bash
   ls ~/.claude/agents/ <project>/.claude/agents/ 2>/dev/null
   ```
2. Scope mit User klaeren: global vs. projekt-lokal.
3. Datei anlegen:
   ```bash
   mkdir -p <scope>/agents/
   ```
4. Agent-Definition gemaess Template schreiben.
5. Dem User die fertige Datei zeigen.
6. Fragen, ob committed werden soll (kein automatisches `git add` /
   `git commit`).
7. Optional: projekt-spezifische `CLAUDE.md` um einen Agent-Eintrag
   ergaenzen.

## Regeln fuer gute Agents

1. **description** klar abgrenzend — enthaelt "Use this agent for X"
   und idealerweise "Do NOT use for Y".
2. **tools** minimal — Subagents mit zu breitem Tool-Set tendieren zu
   Overreach.
3. **Body = System-Prompt** — schreiben, als briefe man einen neuen
   Kollegen, der die aktuelle Conversation nicht kennt.
4. **Kein shared State** zur Haupt-Session annehmen.
5. **Report-Format vorgeben** — der Hauptagent bekommt nur die finale
   Antwort zurueck, also soll sie strukturiert und kurz sein.
6. **Destruktive Aktionen** nur, wenn der Prompt sie explizit
   freigibt. Im Zweifel stoppen und melden.
7. **Model** nur setzen, wenn eine Abweichung vom Session-Modell
   sinnvoll ist (z.B. Haiku fuer schnelle Parallel-Recherchen,
   Sonnet fuer Code-Reviews).
8. **Keine Emojis** in Agent-Dateien.

## Offizielle Referenz

Anthropic Subagents-Dokumentation:
https://code.claude.com/docs/en/subagents

Frontmatter-Felder laut Doku: `name`, `description`, `tools`, `model`,
`color`.
