# Claude Code Workflow

Methodik, Regeln und Templates für die Arbeit mit [Claude Code](https://docs.claude.com/en/docs/claude-code) in echten Projekten — ohne dass der Assistent stillschweigend Schaden anrichtet.

> **In einem Satz:** Ein leichtgewichtiges Regel- und Template-Set, mit dem du Claude Code in produktiven Repos sicher und reproduzierbar einsetzen kannst — mit deutlich weniger Setup-Reibung.

[English version](./README.md)

---

## TL;DR

- **`rules/`** — direkt einsatzbereite Regeln für `~/.claude/rules/`, die typische KI-Failure-Modes hart begrenzen (zu große Dateien, Code-Duplication, Pfad-Raten, UI-Library-Missbrauch).
- **`methodology/`** — sechs Patterns aus echter Projekt-Erfahrung: Session-Start/Ende-Protokolle, Reality-Check, geschützte Pfade, Schreibschutz-Policies, Stop-Hook-Pattern.
- **`templates/`** — `CLAUDE.md.template`, `.env.example`, `settings.example.json` zum Bootstrappen eines neuen Projekts mit diesen Patterns.
- **Fertiges `CLAUDE.md`-Template mit `${ENV}`-Platzhaltern** — `.env` einmal füllen, projekt-spezifische `CLAUDE.md` in Sekunden generieren, kein Leerseiten-Setup-Schmerz.
- **`docs/`** — wie die Schichten zusammenspielen und Verhältnis zum Schwester-Repo [`claude-code-guardrails`](https://github.com/web-werkstatt/claude-code-guardrails).
- **`skills/`** — 11 kuratierte, generische Claude-Code-Skills (Setup, Session-Disziplin, Audit, sichere Arbeitsweise).

Das ist **Methodik + Templates**. Kein Tool. Kein Plugin. Kein `npm install`.

## Scope

Dieses Repo deckt **Workflow und Templates** für Claude Code ab. Du bekommst:

- Ein wiederholbares Setup, das du in jedes neue Projekt kopierst (CLAUDE.md, Settings, Rules).
- Harte Grenzen für typische LLM-Failure-Modes (Dateigröße, Duplikate, Pfad-Raten).
- Ein Onboarding-Ritual (Session-Start- / Session-Ende-Protokoll), das zwischen Sessions trägt.
- Templates mit `${ENV}`-Platzhaltern, damit projekt-spezifische Werte aus der Methodik draußen bleiben.

Was das Repo **nicht** abdeckt:

- Den harten Destructive-Op-Block — siehe [`claude-code-guardrails`](https://github.com/web-werkstatt/claude-code-guardrails).
- Projekt-spezifische Deploy-Skripte, CI/CD, Infrastruktur.
- Tech-Stack-spezifische Patterns über die enthaltenen Rules hinaus (FastAPI, Astro etc. leben in eigenen Skill-Packs).

## Für wen ist das?

- **Solo-Devs**, die Claude Code parallel auf mehreren Projekten nutzen und einen einheitlichen Workflow wollen — ein mentales Modell für viele Repos, statt pro Projekt neu konfigurieren.
- **Kleine Teams**, die KI-generierten Code reviewen und automatische Hard-Limits statt manuelles Mahnen wollen.
- **Agenturen / Werkstätten**, die Multi-Projekt-Setups standardisieren und Templates statt Boilerplate wollen.

Gemeinsame Eigenschaft: Du hast schon erlebt, wie Claude eine Datei auf 1500 Zeilen aufpumpt, einen Pfad halluziniert, oder ein Verzeichnis „aufräumt", das nicht angefasst werden sollte. Du willst das verhindern.

## Welches Problem löst das?

| Failure-Mode | Ohne diese Patterns | Was du mit ihnen bekommst |
|---|---|---|
| KI hängt immer mehr an dieselbe Datei → 2000-Zeilen-Monolith | Manuelles Mahnen, Post-hoc-Refactor | `rules/file-size-limits.md` setzt harte Grenzen pro Dateityp |
| Dieselbe Logik in 5 Files dupliziert | Fällt im Review auf — manchmal | `rules/code-quality-patterns.md` schreibt DRY + Shared Helpers vor |
| KI erfindet Pfade bei Unsicherheit | „Ich speicher das mal nach `~/Dokumente/…`" | `rules/skills-before-guessing.md` zwingt zur Rückfrage |
| Spec sagt X, Repo-Stand ist Y, KI baut nach Spec | Destruktive Korrekturen | `methodology/reality-check-pattern.md` schreibt 3-Zeilen-Check vor |
| Production-Op gemacht (Cron, SSH-Key) aber nicht dokumentiert | Wissen geht zwischen Sessions verloren | `methodology/session-end-protocol.md` fordert expliziten Archiv-Eintrag |
| KI „räumt" Design-Quellen / Archive auf | Echte, unwiederbringliche Verluste | `methodology/protected-paths-pattern.md` + Hook + permissions.deny |
| CLAUDE.md wird zur Halde aus Operativem + Chronik + Strategie | Niemand findet was | `methodology/write-protection-policies.md` trennt nach File-Policy |
| Leerer-Setup-Schmerz bei jedem neuen Projekt | CLAUDE.md immer wieder von null | `templates/CLAUDE.md.template` mit `${ENV}`-Platzhaltern |

## Was bringt dir das konkret?

- **Weniger Produktionsrisiko:** Hooks, geschützte Pfade und Schreibschutz-Policies machen „Oops, ich habe das falsche Verzeichnis gelöscht" extrem unwahrscheinlich.
- **Weniger Review-Zeit:** Die Rules verhindern 2000-Zeilen-Monolithen, Copy-Paste-Logik und wilden UI-Library-Einsatz schon bei der Generierung — nicht erst im Review.
- **Weniger Setup-Reibung:** Neue Projekte starten mit einem fertigen CLAUDE.md, konsistentem Workflow und reproduzierbaren Settings statt ad-hoc-Prompts.

Kurz: Risiko runter, Zeitersparnis, weniger kognitive Last beim Wechsel zwischen Projekten.

## Wie nutzen

### Variante A — schrittweise einzelne Teile übernehmen

1. `rules/*.md` nach `~/.claude/rules/` kopieren. Fertig — wirkt ab nächster Session.
2. Ein oder zwei Methodik-Dokumente lesen, die zum aktuellen Schmerz passen (Start mit `reality-check-pattern.md`).
3. Beim nächsten Projekt-Start: `templates/CLAUDE.md.template` ins Projekt kopieren, Platzhalter füllen.

### Variante B — komplettes Setup für neues Projekt

1. Dieses Repo klonen.
2. [`claude-code-guardrails`](https://github.com/web-werkstatt/claude-code-guardrails) klonen für den Destructive-Op-Hook.
3. `rules/*.md` → `~/.claude/rules/`.
4. `claude-code-guardrails/hooks/block-destructive.sh` → `~/.claude/hooks/`.
5. In deinem neuen Projekt:
   - `templates/CLAUDE.md.template` → `CLAUDE.md`.
   - `templates/.env.example` → `.env`, Werte einsetzen.
   - `templates/settings.example.json` → `.claude/settings.json`, Pfade anpassen.
   - `${PLATZHALTER}` in `CLAUDE.md` durch Werte aus `.env` ersetzen — siehe *Platzhalter ersetzen* unten.
6. `methodology/session-start-protocol.md` einmal lesen. Verinnerlichen.

### Wie `.env` aussieht

Eine minimale `.env` sieht so aus (vollständige Liste in `templates/.env.example`):

```bash
PROJECT_NAME=my-project
PROJECT_DESCRIPTION_ONE_LINE="Eine kurze Beschreibung was das Projekt tut."
DEPLOY_SSH_HOST=my-docker-vm
DEPLOY_SCRIPT=./infrastructure/deploy/deploy.sh
DESIGN_SOURCE_DIR=design-source
TEMPLATE_DIR=design-templates
```

### Platzhalter ersetzen

Das `CLAUDE.md.template` nutzt bash-Style `${VAR_NAME}`-Platzhalter. Einfachste Ersetzung auf Unix-artigen Systemen:

```bash
# Nach .env-Pflege ausführen:
set -a && source .env && set +a
envsubst < templates/CLAUDE.md.template > CLAUDE.md
```

(`envsubst` steckt im `gettext`-Paket der meisten Linux-Distros und ist auf macOS via Homebrew Standard.)

Für feinere Kontrolle oder Nicht-Unix-Umgebungen (Windows ohne WSL, PowerShell-only): Template manuell kopieren und Platzhalter per Hand ersetzen — oder ein kleines Replace-Skript in PowerShell, Node.js oder Python schreiben (~10 Zeilen).

## Repo-Struktur

```
claude-code-workflow/
├── README.md                          # English
├── README.de.md                       # diese Datei
├── LICENSE                            # MIT
├── rules/                             # nach ~/.claude/rules/ kopieren
│   ├── code-quality-patterns.md
│   ├── file-size-limits.md
│   ├── skills-before-guessing.md
│   └── ui-component-libraries.md
├── methodology/                       # einmal lesen, verinnerlichen
│   ├── session-start-protocol.md
│   ├── session-end-protocol.md
│   ├── reality-check-pattern.md
│   ├── protected-paths-pattern.md
│   ├── write-protection-policies.md
│   └── stop-hook-pattern.md
├── templates/                         # neues Projekt bootstrappen
│   ├── CLAUDE.md.template
│   ├── .env.example
│   └── settings.example.json
├── docs/
│   ├── architecture.md                # wie die Schichten zusammenspielen
│   └── relationship-to-guardrails.md  # Aufteilung mit Schwester-Repo
└── skills/                            # 11 kuratierte Skills + README
    ├── README.md
    ├── create-agent/                  # Subagent-Gerüst erstellen
    ├── create-skill/                  # Skill-Gerüst erstellen
    ├── setup-claude-env/              # Stack erkennen + LSP/Rules/Hooks/Agents ergänzen
    ├── claude-features-update/        # Claude-Code-Feature-Nutzung auditieren
    ├── find-skills/                   # Skills via npx skills entdecken
    ├── session-end/                   # Archiv + schlanker Handoff + Commit
    ├── dokumentenaustausch/           # gemeinsamer Datei-Austausch-Ordner
    ├── projekt-audit-kundenplan/      # 6-Phasen Kunden-Projekt-Audit
    ├── owasp-security/                # OWASP Top 10 Präventions-Patterns
    ├── accessibility-a11y/            # WCAG a11y Richtlinien
    └── bulletproof-container/         # Container-Härtung + Vuln-Scan
```

## Verhältnis zu `claude-code-guardrails`

Die beiden Repos sind Geschwister:

- [`claude-code-guardrails`](https://github.com/web-werkstatt/claude-code-guardrails) — **harte Schicht**: PreToolUse-Bash-Hook + `permissions.deny`-Patterns. Install-and-forget-Schutz gegen `rm`, `git rm`, `git restore`, etc.
- **dieses Repo** — **weiche Schicht**: Methodik, Regeln, Templates. Prozess-Wissen, das verinnerlicht statt erzwungen wird.

Für die meisten User: beide installieren. Siehe [`docs/relationship-to-guardrails.md`](./docs/relationship-to-guardrails.md).

## Skills (`skills/`)

11 kuratierte, generische Claude-Code-Skills aus echter Projekt-Nutzung, in vier Gruppen:

- **Setup & Discovery & Meta** — `create-agent`, `create-skill`, `setup-claude-env`, `claude-features-update`, `find-skills`
- **Session-Disziplin** — `session-end`, `dokumentenaustausch`
- **Audit & Kunden-Arbeit** — `projekt-audit-kundenplan`
- **Sichere Arbeitsweise** — `owasp-security`, `accessibility-a11y`, `bulletproof-container`

Siehe [`skills/README.md`](./skills/README.md) für Beschreibung jedes Skills und Installation. Komplett installieren mit `cp -r skills/* ~/.claude/skills/` oder selektiv kopieren.

Projekt-spezifische Skills (Deploy-Skripte, kunden-spezifisches Tooling, interne CMS-Integrationen) und Tech-Stack-spezifische Skills (FastAPI, Astro, Tailwind etc.) sind **nicht** Teil dieses Repos — das gehört in private Projekt-Repos oder eigene Stack-spezifische Skill-Packs.

## Lizenz

MIT — siehe [LICENSE](./LICENSE).

## Mitarbeit

Das ist der öffentliche Auszug eines hauseigenen Workflows. Vorschläge und Korrekturen per Issue / PR sind willkommen. Projekt-spezifische Patterns, die nicht generalisieren, werden abgelehnt — generisch bleiben, klein bleiben.

## Verwandte Arbeit

- [`claude-code-guardrails`](https://github.com/web-werkstatt/claude-code-guardrails) — Schwester-Repo (Destructive-Op-Block).
- [Anthropic Claude Code Docs](https://docs.claude.com/en/docs/claude-code).
