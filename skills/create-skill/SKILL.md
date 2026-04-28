---
name: create-skill
description: Use when the user says "/create-skill [name]", "neuen Skill erstellen", "create skill", or asks to scaffold a new Claude Code skill. Creates a skill directory and SKILL.md following current Anthropic best practices (Opus 4.7 / 2026), including front-loaded description, granular allowed-tools, and correct frontmatter fields.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(ls:*), Bash(mkdir:*), Bash(git status:*), Bash(git add:*), Bash(git diff:*)
argument-hint: [skill-name] [optional description]
---

# Skill erstellen

Erstellt eine neue Claude Code Skill-Definition mit aktueller
Anthropic-Konvention (Frontmatter-Schema, Auto-Invocation-Heuristik,
Minimum-Permissions). Funktioniert fuer globale Skills
(`~/.claude/skills/<name>/`) und Projekt-Skills
(`<project>/.claude/skills/<name>/`).

## Argumente

Der User gibt den Skill-Namen und optional eine Beschreibung an. Falls
nicht angegeben, nachfragen:

- **name** — kebab-case, eindeutig, keine Leerzeichen (z.B. `domain-check`)
- **description** — 1-2 Saetze, "Use when …"-Pattern (siehe unten)
- **trigger-phrasen** — konkrete Woerter, bei denen der Skill aktivieren soll
- **scope** — global (`~/.claude/skills/`) oder projekt-lokal
  (`<project>/.claude/skills/` oder `<project>/codex-skills/`)
- **destruktive Aktionen?** — wenn ja, `disable-model-invocation: true`
  ueberlegen, damit der Skill nur manuell per `/name` gestartet wird

## Verzeichnisstruktur

```
<scope>/<name>/
  SKILL.md              # Pflicht
  references/           # optional — laengere Referenzinhalte auslagern
    guide.md
  scripts/              # optional — Hilfs-Skripte
    helper.sh
  examples/             # optional — Beispiele
    sample.md
```

Supporting Files muessen in `SKILL.md` verlinkt sein, sonst werden sie
nicht gefunden (`See [references/guide.md](references/guide.md)`).

## Frontmatter-Schema (Stand 2026, Opus 4.7)

```yaml
---
name: <kebab-case>                      # optional — default ist Verzeichnisname
description: Use when ...               # Pflicht, max 1.536 Zeichen (inkl. when_to_use)
when_to_use: ...                        # optional — zusaetzliche Trigger-Hinweise
allowed-tools: Read, Write, Bash(git status:*), Bash(git add:*)   # minimum principle
argument-hint: [arg1] [arg2]            # optional — fuer Slash-Autocomplete
disable-model-invocation: true          # optional — nur manuell via /name
user-invocable: false                   # optional — Skill aus /-Menue verstecken
model: claude-haiku-4-5-20251001        # optional — eigenes Modell fuer diesen Skill
effort: low                             # optional — low | medium | high | xhigh | max
context: fork                           # optional — isolierter Subagent-Context
agent: Explore                          # optional — bevorzugter Subagent-Typ
paths: ["src/**/*.ts"]                  # optional — Glob-Muster fuer Auto-Kontext
shell: bash                             # optional — bash (default) | powershell
hooks:                                  # optional — Lifecycle-Hooks
  - event: ...
---
```

Nur Felder setzen, die wirklich gebraucht werden. Default fuer einen
einfachen User-getriggerten Skill reicht: `name`, `description`,
`allowed-tools`.

## description-Heuristik

Anthropic empfiehlt front-loaded Trigger-Keywords am Anfang der
`description`. Claude Code liest sie zum Auto-Matching.

Gut:

```yaml
description: Use when ending a session, saying "Feierabend", or asking to push changes. Archives session summary, commits, optionally pushes.
```

Weniger gut:

```yaml
description: This skill is there to help you with your session workflow and might be useful at some point.
```

Richtlinien:

- Deutsche Trigger-Phrasen als Anfuehrungszeichen-Liste einbauen, wenn
  der User auf deutsch arbeitet
- max 1.536 Zeichen inkl. `when_to_use`
- bei Auto-Aktivierung: wichtigstes Schluesselwort im ersten Satzdrittel
- bei manuellen Skills (`disable-model-invocation: true`): Trigger-
  Beispiel `/skill-name [arg]` mit aufnehmen

## allowed-tools — Minimum Principle

Nur die Tools listen, die der Skill wirklich braucht. Bash-Sub-Commands
granular angeben:

```yaml
# Gut — granular, pre-approved:
allowed-tools: Read, Write, Bash(git status:*), Bash(git add:*), Bash(git commit:*)

# Grob — aber erlaubt, wenn noetig:
allowed-tools: Read, Write, Bash

# Zu grob — vermeiden wenn moeglich:
allowed-tools: *
```

Destruktive Operationen (`Bash(git push:*)`, `Bash(rm:*)`,
`Bash(docker rm:*)`): nur aufnehmen, wenn der Skill sie tatsaechlich
braucht, und im Body des Skills explizit ueber Rueckfrage absichern.

## SKILL.md Body-Template

```markdown
---
name: <name>
description: Use when <Hauptfall>. <Trigger-Phrasen>. <1-Satz Wirkung>.
allowed-tools: Read, Write, Grep, Bash(<subcmd>:*)
argument-hint: [<arg>]
---

# <Titel>

<1-2 Saetze: was der Skill tut, wen er adressiert.>

## Wann aktivieren

- "<Trigger-Phrase 1>"
- "<Trigger-Phrase 2>"
- explizit: `/<name> [<arg>]`

## Voraussetzungen

- <z.B. Git-Repo, bestimmte Tools installiert, .env vorhanden>

## Ablauf

### 1. <Schritt 1 — kurzer Titel>

<Konkreter Befehl oder Handlung>

```bash
<befehl>
```

### 2. <Schritt 2>

<Details>

### 3. Ergebnis melden

```
<Output-Template>
```

## Repo-Konventionen respektieren

- CLAUDE.md / AGENTS.md im Repo lesen
- MANUAL-/DASHBOARD-GENERATED-Bloecke nicht ueberschreiben
- Append-only-Dateien nur ergaenzen

## Destruktive Aktionen

- <Was destruktiv ist und wie es abgesichert wird — meist Rueckfrage>

## Hinweise

- <Einschraenkungen, Rand-Faelle>
```

## Workflow

1. Skill-Name validieren (kebab-case, kein Duplikat):
   ```bash
   ls ~/.claude/skills/ <project>/.claude/skills/ 2>/dev/null
   ```
2. Scope mit User klaeren: global vs. projekt-lokal.
3. Verzeichnis anlegen:
   ```bash
   mkdir -p <scope>/<name>/
   ```
4. `SKILL.md` gemaess obigem Template schreiben.
5. Dem User das Ergebnis zeigen.
6. Fragen, ob committed werden soll (kein automatischer `git add` /
   `git commit`).
7. Optional: projekt-spezifische `CLAUDE.md` um einen Skill-Eintrag
   ergaenzen, wenn der Skill dort gefuehrt wird.

## Regeln fuer gute Skills

1. **description front-loaded** mit Trigger-Keywords.
2. **allowed-tools granular** — Minimum Principle.
3. **Konkrete Befehle**, keine vagen Beschreibungen.
4. **Destruktive Aktionen** immer mit Rueckfrage absichern (kein auto
   push, kein auto rm, kein auto deploy).
5. **Keine hardcoded Model-IDs** im Skill-Body, ausser das ist bewusst
   so fuer diesen Skill gewollt. `model`-Feld nur setzen, wenn der
   Skill mit einem anderen Modell laufen soll als die Session.
6. **Keine Emojis** im Skill-Body (bleibt werkzeugagnostisch und besser
   parsebar).
7. **Dateipfade absolut**, wenn sie ausserhalb des Arbeitsverzeichnisses
   liegen.
8. **Supporting Files** verlinken, nicht in die Haupt-SKILL.md
   reinkopieren.
9. **Sprache**: `description` und Trigger-Phrasen zweisprachig
   (englisch + deutsch), Body auf deutsch, wenn das Zielpublikum
   deutsch ist.

## Offizielle Referenz

Anthropic Skill-Dokumentation: https://code.claude.com/docs/en/skills

Felder, die dort als aktuell dokumentiert sind: `name`, `description`,
`when_to_use`, `allowed-tools`, `argument-hint`,
`disable-model-invocation`, `user-invocable`, `model`, `effort`,
`context`, `agent`, `paths`, `shell`, `hooks`.
