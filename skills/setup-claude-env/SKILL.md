---
name: setup-claude-env
description: Richtet Claude Code Entwicklungsumgebung ein (LSP, Rules, Hooks, MCP Server, Agenten). Funktioniert fuer neue UND bestehende Projekte - erkennt vorhandene Konfiguration und ergaenzt fehlende Teile. Aktiviere bei "Umgebung einrichten", "Claude Setup", "Projekt-Setup", "LSP einrichten", "Hooks einrichten", "Rules einrichten", "MCP einrichten", "Agenten einrichten", "setup-claude-env".
user_invocable: true
---

# Claude Code Entwicklungsumgebung einrichten

Analysiert ein Projekt (neu oder bestehend) und richtet fehlende LSP, Rules, Hooks, MCP Server und Agenten ein.
Bei bestehenden Projekten wird NICHTS ueberschrieben - nur fehlende Teile werden ergaenzt.

## Ablauf

### Schritt 1: Bestandsaufnahme (bestehende Config erkennen)

ZUERST pruefen was bereits existiert, damit nichts ueberschrieben wird:

```bash
echo "=== Bestehende Claude-Config ==="

# CLAUDE.md vorhanden?
ls CLAUDE.md 2>/dev/null && echo "CLAUDE.md: VORHANDEN (wird NICHT angefasst)" || echo "CLAUDE.md: fehlt"

# Rules pruefen
if ls .claude/rules/*.md 2>/dev/null; then
  echo "Rules: VORHANDEN ($(ls .claude/rules/*.md | wc -l) Dateien)"
  ls .claude/rules/*.md
else
  echo "Rules: fehlen -> werden erstellt"
fi

# Hooks pruefen
if [ -f .claude/hooks.json ]; then
  echo "Hooks: VORHANDEN"
  python3 -c "import json; d=json.load(open('.claude/hooks.json')); print(f'  {len(d.get(\"hooks\", []))} Hooks konfiguriert')"
else
  echo "Hooks: fehlen -> werden erstellt"
fi

# MCP pruefen
if [ -f .mcp.json ]; then
  echo "MCP: VORHANDEN"
  python3 -c "import json; d=json.load(open('.mcp.json')); [print(f'  - {k}') for k in d.get('mcpServers', {}).keys()]"
else
  echo "MCP: fehlt -> wird erstellt"
fi

# Agenten pruefen
if ls .claude/agents/*.md 2>/dev/null; then
  echo "Agenten: VORHANDEN ($(ls .claude/agents/*.md | wc -l) Agenten)"
  ls .claude/agents/*.md
else
  echo "Agenten: fehlen -> werden erstellt"
fi

# Memory pruefen
echo ""
echo "=== Memory ==="
PROJECT_PATH=$(pwd)
MEMORY_DIR="$HOME/.claude/projects/$(echo $PROJECT_PATH | sed 's|/|-|g' | sed 's|^-||')/memory"
if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
  LINES=$(wc -l < "$MEMORY_DIR/MEMORY.md")
  echo "MEMORY.md: VORHANDEN ($LINES Zeilen)"
  ls "$MEMORY_DIR"/*.md 2>/dev/null | grep -v MEMORY.md | while read f; do echo "  Detail: $(basename $f)"; done
else
  echo "MEMORY.md: fehlt -> wird vorgeschlagen"
fi

# LSP Plugins pruefen (global)
echo ""
echo "=== Globale LSP Plugins ==="
python3 -c "
import json
try:
    d = json.load(open('$HOME/.claude/settings.json'))
    plugins = d.get('enabledPlugins', {})
    for p, enabled in plugins.items():
        if 'lsp' in p.lower():
            print(f'  {p}: {\"aktiv\" if enabled else \"inaktiv\"}')
except: print('  Keine settings.json gefunden')
"
```

### Schritt 2: Tech-Stack analysieren

**Hinweis:** Die unten gezeigten Detection-Befehle sind self-contained. Fuer exotische Stacks (z.B. Erlang, Crystal) eigene Erkennungs-Regeln ergaenzen.

Das Detection-Script erkennt:
- **10+ Sprachen:** Node.js/TS, Python, Go, Rust, PHP, Java, Ruby, Swift, Kotlin, Elixir
- **Node.js Frameworks:** React, Next.js, Vue, Nuxt, Angular, Svelte, Astro, Payload, Express, NestJS, Fastify, Hono, Remix, Gatsby, Solid.js, Qwik
- **Python Frameworks:** FastAPI, Flask, Django, Starlette, SQLAlchemy, Alembic, Celery, Pydantic
- **PHP Frameworks:** Laravel, Symfony, WordPress, Drupal, Magento, TYPO3, Contao, Craft CMS, Statamic
- **WordPress:** 5 Erkennungsmethoden (Core, Theme, Plugin, Composer/Bedrock, Standalone Theme)
- **CMS:** Payload, Strapi, Directus, Ghost, Contentful, Sanity
- **CSS/UI:** Tailwind, Bootstrap, Bulma, Material UI, Chakra, Ant Design, shadcn/ui, Radix, Styled Components, Emotion, SCSS
- **Bundler:** Vite, Webpack, esbuild, Turbo, Bun
- **Datenbanken:** PostgreSQL, MySQL/MariaDB, MongoDB, Redis, SQLite + ORMs (Prisma, Drizzle, TypeORM, Sequelize)
- **Infrastruktur:** Docker, GitHub Actions, GitLab CI, Jenkins, Vercel, Netlify, Fly.io, Terraform, Kubernetes

```bash
echo "=== Tech-Stack Erkennung ==="

# Sprachen
ls package.json 2>/dev/null && echo "Node.js/TypeScript Projekt"
ls requirements.txt pyproject.toml setup.py Pipfile 2>/dev/null && echo "Python Projekt"
ls go.mod 2>/dev/null && echo "Go Projekt"
ls Cargo.toml 2>/dev/null && echo "Rust Projekt"
ls composer.json 2>/dev/null && echo "PHP Projekt"
ls *.java pom.xml build.gradle 2>/dev/null && echo "Java Projekt"
ls *.rb Gemfile 2>/dev/null && echo "Ruby Projekt"
ls mix.exs 2>/dev/null && echo "Elixir Projekt"

# Frameworks erkennen (package.json)
if [ -f package.json ]; then
  echo "--- Node.js Frameworks ---"
  for fw in react next vue nuxt angular svelte sveltekit astro payload express nestjs fastify hono remix gatsby solid-js qwik; do
    grep -q "\"$fw\"" package.json 2>/dev/null && echo "  Framework: $fw"
  done
fi

# Python Frameworks erkennen
for f in requirements.txt pyproject.toml setup.py Pipfile; do
  if [ -f "$f" ]; then
    grep -ioP "(fastapi|flask|django|starlette|uvicorn|sqlalchemy|alembic|celery|dramatiq|pydantic)" "$f" 2>/dev/null | sort -u | while read fw; do echo "  Python: $fw"; done
  fi
done

# PHP Frameworks erkennen
if [ -f composer.json ]; then
  echo "--- PHP Frameworks ---"
  for fw in laravel symfony wordpress drupal magento typo3 contao craft-cms statamic; do
    grep -qi "$fw" composer.json 2>/dev/null && echo "  PHP: $fw"
  done
fi

# WordPress erkennen (5 Methoden)
echo "--- WordPress ---"
ls wp-config.php 2>/dev/null && echo "  WordPress Core erkannt"
ls wp-content/themes/*/style.css 2>/dev/null && echo "  WordPress Theme erkannt"
ls wp-content/plugins/*/plugin.php 2>/dev/null && echo "  WordPress Plugin erkannt"
grep -qi "wordpress\|wpackagist" composer.json 2>/dev/null && echo "  WordPress via Composer (Bedrock/Roots)"
ls functions.php 2>/dev/null && echo "  WordPress Theme-Functions erkannt"

# CMS erkennen
echo "--- CMS ---"
grep -qi "payload" package.json 2>/dev/null && echo "  Payload CMS"
grep -qi "strapi" package.json 2>/dev/null && echo "  Strapi"
grep -qi "ghost" package.json docker-compose*.yml 2>/dev/null && echo "  Ghost"

# CSS Frameworks
echo "--- CSS/UI Frameworks ---"
grep -qi "tailwindcss" package.json 2>/dev/null && echo "  Tailwind CSS"
grep -qi "bootstrap" package.json 2>/dev/null && echo "  Bootstrap"
grep -qi "material-ui\|@mui" package.json 2>/dev/null && echo "  Material UI"
grep -qi "shadcn" package.json 2>/dev/null && echo "  shadcn/ui"

# Docker pruefen
ls docker-compose*.yml Dockerfile 2>/dev/null && echo "Docker: vorhanden"

# Datenbank erkennen
echo "--- Datenbanken ---"
grep -ril "postgres" docker-compose*.yml .env* 2>/dev/null | head -1 > /dev/null && echo "  PostgreSQL erkannt"
grep -ril "mysql\|mariadb" docker-compose*.yml .env* 2>/dev/null | head -1 > /dev/null && echo "  MySQL/MariaDB erkannt"
grep -ril "mongodb\|mongo" docker-compose*.yml .env* 2>/dev/null | head -1 > /dev/null && echo "  MongoDB erkannt"
grep -ril "redis" docker-compose*.yml .env* 2>/dev/null | head -1 > /dev/null && echo "  Redis erkannt"

# ORM erkennen
grep -qi "prisma" package.json 2>/dev/null && echo "  Prisma ORM"
grep -qi "drizzle" package.json 2>/dev/null && echo "  Drizzle ORM"
grep -qi "typeorm" package.json 2>/dev/null && echo "  TypeORM"

# Projektstruktur erkennen (Monorepo, Multi-Service, etc.)
echo "--- Projektstruktur ---"
DIRS=$(find . -maxdepth 2 -name "package.json" -o -name "requirements.txt" -o -name "pyproject.toml" 2>/dev/null | wc -l)
[ "$DIRS" -gt 2 ] && echo "  Multi-Service / Monorepo erkannt ($DIRS Unterprojekte)"

# Sprint-/Planungs-Dateien erkennen
ls sessions/sprints/*.md TODO.md next-session.md 2>/dev/null && echo "  Sprint-Management erkannt"

# CI/CD erkennen
ls .github/workflows/*.yml .gitlab-ci.yml Jenkinsfile 2>/dev/null && echo "  CI/CD Pipeline erkannt"

# Ports erkennen (fuer Health-Checks)
echo "--- Ports ---"
grep -oP '"\d{4,5}:\d{4,5}"' docker-compose*.yml 2>/dev/null | sort -u | head -10
```

### Schritt 3: LSP Server pruefen und installieren

**Hinweis:** Die LSP-Matrix unten deckt die haeufigsten 12+ Stacks ab. Fuer Sprach-Spezialitaeten (Erlang, Haskell, Crystal, Elixir-LSP) eigene Recherche.

IMMER die neueste Version installieren (`@latest`). Nur installieren was fehlt:

| Erkannt | LSP Server | Install | Claude Plugin |
|---------|-----------|---------|---------------|
| Python | Pyright | `npm i -g pyright@latest` | `pyright-lsp@claude-plugins-official` |
| TypeScript/React | TS LSP | `npm i -g typescript@latest typescript-language-server@latest` | `typescript-lsp@claude-plugins-official` |
| Astro | Astro LSP | `npm i -g @astrojs/language-server@latest` | - |
| PHP | Intelephense | `npm i -g intelephense@latest` | `php-lsp@claude-plugins-official` |
| Java | JDTLS | via Plugin | `jdtls-lsp@claude-plugins-official` |
| Go | gopls | `go install golang.org/x/tools/gopls@latest` | - |
| Vue | Vue LSP | `npm i -g @vue/language-server@latest` | - |
| Svelte | Svelte LSP | `npm i -g svelte-language-server@latest` | - |
| Tailwind | Tailwind LSP | `npm i -g @tailwindcss/language-server@latest` | - |
| CSS/HTML/JSON | vscode-langservers | `npm i -g vscode-langservers-extracted@latest` | - |
| YAML | YAML LSP | `npm i -g yaml-language-server@latest` | - |
| Docker | Dockerfile LSP | `npm i -g dockerfile-language-server-nodejs@latest` | - |

```bash
# Nur fehlende installieren (Beispiel - alle erkannten Sprachen pruefen)
which pyright > /dev/null 2>&1 || npm install -g pyright@latest
which typescript-language-server > /dev/null 2>&1 || npm install -g typescript@latest typescript-language-server@latest
```

Plugins in `~/.claude/settings.json` unter `enabledPlugins` aktivieren (nur fehlende hinzufuegen).
Nur 4 offizielle LSP-Plugins existieren: pyright-lsp, typescript-lsp, php-lsp, jdtls-lsp.

**Smoke Test:**
- LSP `documentSymbol` auf eine Haupt-Datei ausfuehren
- LSP `hover` auf einen Import/Typ ausfuehren
- LSP `findReferences` auf eine zentrale Funktion ausfuehren

### Schritt 4: Rules ergaenzen (NICHT ueberschreiben)

**Hinweis:** Die Rule-Datei-Vorlagen unten sind Stichworte. Vollstaendige Beispiel-Inhalte koennen aus `claude-code-workflow/rules/` (https://github.com/web-werkstatt/claude-code-workflow/tree/main/rules) uebernommen und projekt-spezifisch erweitert werden.

```bash
mkdir -p .claude/rules
```

**WICHTIG:** Bestehende Rule-Dateien NIEMALS ueberschreiben! Nur neue erstellen fuer Bereiche die noch keine Rules haben.

Fuer JEDE erkannte Technologie OHNE bestehende Rule eine Datei aus den Templates erstellen.

**Verfuegbare Templates (in rules-templates-full.md):**

| Stack | Rule-Datei | Glob-Pattern |
|-------|-----------|-------------|
| Python/FastAPI | `api-backend.md` | `backend*/**/*.py,api*/**/*.py` |
| Django | `django-backend.md` | `**/views.py,**/models.py,**/serializers.py` |
| Flask | `flask-backend.md` | `**/app.py,**/routes/**/*.py` |
| React/TypeScript | `react-frontend.md` | `**/src/**/*.tsx,**/src/**/*.ts` |
| Next.js | `nextjs.md` | `**/app/**/*.tsx,**/pages/**/*.tsx` |
| Vue.js | `vue-frontend.md` | `**/src/**/*.vue` |
| Nuxt.js | `nuxt.md` | `**/pages/**/*.vue,**/server/**/*.ts` |
| Svelte/SvelteKit | `svelte.md` | `**/src/**/*.svelte` |
| Astro | `astro-frontend.md` | `**/src/**/*.astro` |
| PHP (PSR-12) | `php-backend.md` | `**/*.php` |
| Laravel | `laravel.md` | `app/**/*.php,routes/**/*.php` |
| Symfony | `symfony.md` | `src/**/*.php,templates/**/*.twig` |
| WordPress Theme | `wordpress-theme.md` | `wp-content/themes/**/*.php` |
| WordPress Plugin | `wordpress-plugin.md` | `wp-content/plugins/**/*.php` |
| Go | `go-backend.md` | `**/*.go` |
| Rust | `rust.md` | `**/*.rs` |
| Ruby/Rails | `rails.md` | `app/**/*.rb` |
| Docker/Infra | `infrastructure.md` | `**/Dockerfile,**/docker-compose*.yml` |
| Tailwind CSS | `tailwind.md` | `tailwind.config.*` |
| Security | `security.md` | `**/*.py,**/*.ts,**/*.php` |

**IMMER zusaetzlich erstellen wenn Frontend erkannt:**
- `security.md` - Sprachuebergreifende Security-Rules

### Schritt 5: Hooks ergaenzen (NICHT ueberschreiben)

**Bei bestehender hooks.json:** Bestehende Hooks lesen, nur fehlende Hook-Typen hinzufuegen.
**Bei fehlender hooks.json:** Neue Datei mit Standard-Hooks erstellen.

Standard-Hooks (nur erstellen wenn dieser Typ noch nicht existiert):

**1. Session-Start Health-Check** - Ports und URLs aus docker-compose/CLAUDE.md ableiten:
```json
{
  "matcher": { "event": "notification", "name": "session_start" },
  "hooks": [{
    "type": "command",
    "command": "bash -c '[Health-Checks fuer erkannte Services mit korrekten Ports]'"
  }]
}
```

**2. Dateigroessen-Warnung:**
```json
{
  "matcher": { "event": "tool_use", "tool_name": "Write", "file_paths": ["**/*.py", "**/*.ts", "**/*.tsx"] },
  "hooks": [{
    "type": "command",
    "command": "bash -c 'FILE=\"$CLAUDE_FILE_PATH\"; if [ -f \"$FILE\" ]; then LINES=$(wc -l < \"$FILE\"); LIMIT=500; echo $FILE | grep -q \"\\.tsx\\\\?$\" && LIMIT=300; if [ $LINES -gt $LIMIT ]; then echo \"WARNUNG: $FILE hat $LINES Zeilen (max $LIMIT)\"; fi; fi'"
  }]
}
```

**3. Secret-Detection:**
```json
{
  "matcher": { "event": "tool_use", "tool_name": "Write", "file_paths": ["**/*.py", "**/*.ts", "**/*.tsx", "**/*.env*"] },
  "hooks": [{
    "type": "command",
    "command": "bash -c 'FILE=\"$CLAUDE_FILE_PATH\"; if [ -f \"$FILE\" ]; then if grep -Pn \"(AKIA[A-Z0-9]{16}|sk-[a-zA-Z0-9]{48}|ghp_[a-zA-Z0-9]{36})\" \"$FILE\" 2>/dev/null | head -3; then echo \"WARNUNG: Hartcodierte Secrets gefunden!\"; fi; fi'"
  }]
}
```

### Schritt 6: MCP Server ergaenzen (NICHT ueberschreiben)

**Bei bestehender .mcp.json:** Bestehende Server beibehalten, nur fehlende hinzufuegen.
**Bei fehlender .mcp.json:** Neue Datei erstellen.

MCP Server nur hinzufuegen wenn die entsprechende Technologie erkannt wurde:

| Erkannt | MCP Server | Install |
|---------|-----------|---------|
| PostgreSQL | `@modelcontextprotocol/server-postgres` | `npm i -g @modelcontextprotocol/server-postgres` |
| MySQL | `@modelcontextprotocol/server-mysql` | `npm i -g @modelcontextprotocol/server-mysql` |
| GitHub/Gitea | `@modelcontextprotocol/server-github` | `npm i -g @modelcontextprotocol/server-github` |

**DB-Credentials:** Aus docker-compose.yml, .env, oder secrets/ Dateien auslesen. URL-encode Sonderzeichen im Passwort (/ -> %2F etc.).

**Wichtig:** Den User nach Credentials fragen wenn sie nicht automatisch gefunden werden. NIEMALS Dummy-Credentials einsetzen.

### Schritt 7: Agenten einrichten (NICHT ueberschreiben)

```bash
mkdir -p .claude/agents
```

**WICHTIG:** Bestehende Agenten-Dateien NIEMALS ueberschreiben! Nur fehlende Agenten erstellen.

#### Kern-Agenten (IMMER erstellen wenn sie fehlen)

Diese Agenten sind projektunabhaengig und bringen in jedem Projekt Mehrwert:

**1. sprint-orchestrator.md** - Koordiniert parallele Sprint-Tasks:
```markdown
---
name: sprint-orchestrator
description: Use this agent when you need to coordinate and manage multiple parallel sprint tasks by spawning specialized sub-agents. This agent should be activated at the beginning of a sprint or when complex multi-task coordination is required. The agent will analyze sprint plans, delegate tasks to appropriate specialized agents, and maintain communication between them to ensure efficient parallel execution.
model: sonnet
color: yellow
---

# Agent: Sprint Orchestrator

## Aufgabe
Koordiniert parallele Sprint-Aufgaben durch Delegation an spezialisierte Sub-Agenten.

## Workflow
1. Sprint-Plan lesen und Tasks identifizieren
2. Abhaengigkeiten zwischen Tasks erkennen
3. Unabhaengige Tasks parallel an Sub-Agenten delegieren
4. Fortschritt ueberwachen und bei Blockern eingreifen
5. Ergebnisse zusammenfuehren und validieren
```

**2. sprint-quality-guardian.md** - Ueberwacht Sprint-Konformitaet:
```markdown
---
name: sprint-quality-guardian
description: Use this agent when you need to monitor and ensure strict adherence to sprint plans during development work. This agent should be activated at the beginning of any sprint implementation, when reviewing completed work against sprint specifications, or when there are concerns about deviations from planned requirements.
model: sonnet
color: red
---

# Agent: Sprint Quality Guardian

## Aufgabe
Ueberwacht dass Implementierungen exakt dem Sprint-Plan entsprechen - keine Vereinfachungen, keine Auslassungen.

## Pruefungen
1. Jede Anforderung aus dem Sprint-Plan ist implementiert
2. Keine Features hinzugefuegt die nicht im Plan stehen
3. Akzeptanzkriterien sind erfuellt
4. Code-Standards eingehalten
```

**3. sprint-progress-tracker.md** - Dokumentiert Fortschritt:
```markdown
---
name: sprint-progress-tracker
description: Use this agent when a sprint task or component has been completed and needs to be documented with timestamp, status update, and notification to other involved agents. This agent should be triggered automatically after each sprint plan item completion to maintain real-time progress tracking and team coordination.
model: sonnet
color: green
---

# Agent: Sprint Progress Tracker

## Aufgabe
Dokumentiert abgeschlossene Sprint-Tasks mit Zeitstempel und Status.

## Workflow
1. Abgeschlossenen Task identifizieren
2. Zeitstempel und Status dokumentieren
3. Sprint-Datei aktualisieren
4. Abhaengige Tasks benachrichtigen
```

#### Stack-spezifische Agenten (NUR erstellen wenn Tech-Stack passt)

Basierend auf dem erkannten Tech-Stack zusaetzliche Agenten erstellen:

**Wenn GUI/Frontend erkannt (React, Vue, Angular, Astro, Svelte):**

```markdown
---
name: gui-agent-executor
description: Use this agent when you need to implement GUI features, especially global theme systems, CSS architectures, or UI components. This agent specializes in creating centralized, maintainable GUI systems that work across entire applications.
model: sonnet
color: blue
---

# Agent: GUI Executor

## Aufgabe
Implementiert GUI-Features: Theme-Systeme, CSS-Architekturen, UI-Komponenten.

## Prinzipien
- Zentrales Theme-System (CSS Custom Properties)
- Konsistenz ueber alle Seiten
- Dark/Light Mode Support
- Responsive Design
- Accessibility (WCAG 2.1)
```

**Wenn Scraping/Crawler/Migration erkannt (Playwright vorhanden, oder Migration von anderem System):**

```markdown
---
name: website-scraper-agent
description: Use this agent for Playwright-based website scraping, content migration, or data extraction from external websites. Handles navigation, screenshots, data parsing, and structured output.
model: sonnet
color: purple
---

# Agent: Website Scraper

## Aufgabe
Fuehrt Playwright-basiertes Scraping und Content-Migration durch.

## Workflow
1. Ziel-URLs identifizieren
2. Seiten navigieren und Inhalte extrahieren
3. Daten strukturiert speichern
4. Screenshots als visuelle Referenz
```

**Wenn Dokumentation/Features-Verzeichnis erkannt:**

```markdown
---
name: assistant-prompt-analyzer
description: Use this agent when new features are implemented and need to be documented. This agent automatically creates comprehensive documentation for features and places them in the correct /features/ subdirectory structure.
model: sonnet
color: green
---

# Agent: Feature Dokumentation

## Aufgabe
Erstellt automatisch Dokumentation fuer neue Features.

## Workflow
1. Implementierung analysieren
2. Dokumentation erstellen (Zweck, API, Beispiele)
3. In korrektes Unterverzeichnis ablegen
4. Index aktualisieren
```

**Wenn Docker/Multi-Container erkannt:**

```markdown
---
name: infrastructure-agent
description: Use this agent for Docker container management, infrastructure debugging, service health monitoring, and deployment tasks. Handles container logs, network issues, volume management, and multi-service orchestration.
model: sonnet
color: orange
---

# Agent: Infrastructure

## Aufgabe
Verwaltet Docker-Container, debuggt Infrastruktur-Probleme, ueberwacht Service-Health.

## Faehigkeiten
- Container-Logs analysieren
- Netzwerk-Probleme debuggen
- Volume-Management
- Multi-Service Orchestrierung
- Health-Check Auswertung
```

**Wenn Datenbank mit komplexem Schema erkannt (>10 Tabellen):**

```markdown
---
name: database-agent
description: Use this agent for database schema analysis, migration planning, query optimization, and data integrity checks. Handles complex joins, index recommendations, and migration scripts.
model: sonnet
color: cyan
---

# Agent: Database

## Aufgabe
Analysiert DB-Schema, plant Migrationen, optimiert Queries.

## Faehigkeiten
- Schema-Analyse und Dokumentation
- Migrations-Planung (vorwaerts + rueckwaerts)
- Query-Optimierung und Index-Empfehlungen
- Daten-Integritaets-Pruefungen
```

**Wenn API-Backend erkannt (FastAPI, Express, Django REST, NestJS):**

```markdown
---
name: api-test-agent
description: Use this agent for comprehensive API endpoint testing, including happy path, error cases, edge cases, authentication, and performance. Generates test suites and runs them automatically.
model: sonnet
color: teal
---

# Agent: API Tester

## Aufgabe
Erstellt und fuehrt umfassende API-Tests aus.

## Test-Kategorien
- Happy Path (CRUD Operationen)
- Fehlerbehandlung (400, 401, 403, 404, 500)
- Edge Cases (leere Felder, Grenzwerte, Unicode)
- Authentifizierung/Autorisierung
- Performance (Response-Zeiten)
```

#### Entscheidungsmatrix

**Hinweis:** Die hier gezeigten Agent-Templates sind self-contained. Spezialisierte Agenten (z.B. fuer WordPress-Theme-Reviews oder Laravel-Migrations) koennen analog dazu erstellt werden.

| Erkannter Stack | Agenten die erstellt werden |
|----------------|---------------------------|
| **Jedes Projekt** | sprint-orchestrator, sprint-quality-guardian, sprint-progress-tracker |
| + Frontend (React/Vue/Astro/Svelte/Angular) | + gui-agent-executor |
| + CSS Framework (Tailwind/Bootstrap/etc.) | + gui-agent-executor (falls noch nicht) |
| + Frontend mit > 10 Components | + gui-ux-agent (Accessibility, Performance, Core Web Vitals) |
| + > 20 Quelldateien | + refactoring-agent (Code Smells, DRY, Complexity) |
| + Web-App (IMMER) | + security-agent (OWASP Top 10, Secrets, Dependencies, Headers) |
| + WordPress erkannt | + wordpress-agent (Theme/Plugin, Security, WP-CLI) |
| + Laravel erkannt | + laravel-agent (Eloquent, Policies, Artisan) |
| + Playwright / Migration | + website-scraper-agent |
| + features/ oder docs/ Verzeichnis | + assistant-prompt-analyzer |
| + Docker / Multi-Container | + infrastructure-agent |
| + DB erkannt (jede Art) | + database-agent |
| + API Backend (jedes Framework) | + api-test-agent |

### Schritt 8: Memory-Eintrag erstellen/aktualisieren

Nach Abschluss aller Setup-Schritte einen projektbezogenen Memory-Eintrag vorschlagen oder aktualisieren.

#### Memory-Verzeichnis ermitteln

Das Memory-Verzeichnis leitet sich vom Projektpfad ab:
```bash
# Projektpfad ermitteln (pwd mit / durch - ersetzt)
PROJECT_PATH=$(pwd)
# Claude Memory-Pfad: ~/.claude/projects/<escaped-path>/memory/
MEMORY_DIR="$HOME/.claude/projects/$(echo $PROJECT_PATH | sed 's|/|-|g' | sed 's|^-||')/memory"
echo "Memory-Verzeichnis: $MEMORY_DIR"
ls "$MEMORY_DIR/MEMORY.md" 2>/dev/null && echo "MEMORY.md existiert bereits" || echo "MEMORY.md fehlt"
```

#### Bei bestehender MEMORY.md: Pruefen und ergaenzen

Bestehende MEMORY.md lesen. Nur ergaenzen wenn die folgenden Informationen noch NICHT enthalten sind.
NIEMALS bestehende Eintraege ueberschreiben oder entfernen.

#### Bei fehlender MEMORY.md: Neue erstellen

```bash
mkdir -p "$MEMORY_DIR"
```

#### Memory-Inhalt generieren

Basierend auf dem erkannten Tech-Stack einen knappen Memory-Eintrag erstellen/ergaenzen.

**Vorlage (anpassen an erkannten Stack):**

```markdown
# [Projektname] Projekt-Memory

## Tech-Stack
- [Erkannte Sprachen, Frameworks, Datenbanken - KEINE Versionsnummern]
- [z.B. "FastAPI + React + PostgreSQL + Docker"]

## Projekt-Struktur
- [Wichtigste Verzeichnisse und was sie enthalten]
- [z.B. "backend/ = FastAPI API, frontend/ = React Admin, web/ = Astro Public"]

## Eingerichtete Claude-Umgebung
- LSP: [welche aktiv]
- Rules: [Anzahl] Dateien in .claude/rules/
- Hooks: [Anzahl] Hooks (Health-Check, Dateigroesse, Secrets)
- MCP: [welche Server]
- Agenten: [Anzahl] ([Namen])

## Deploy-Befehle
- [Falls erkannt, z.B. deploy-Script Pfade und wichtigste Befehle]

## Ports
- [Service-Ports aus docker-compose, z.B. "API: 8080, DB: 5432, Frontend: 3000"]
```

#### Sicherheitsregeln fuer Memory

VERBOTEN in Memory-Eintraegen:
- Passwoerter, API-Keys, Tokens, Secrets
- DB-Connection-Strings mit Credentials
- SSH-Keys oder private Schluessel
- Benutzernamen mit Passwoertern
- IP-Adressen von Production-Servern (nur wenn in CLAUDE.md bereits oeffentlich)

ERLAUBT:
- Tech-Stack Uebersicht
- Verzeichnisstruktur
- Port-Nummern (lokal)
- Deploy-Befehlsnamen (ohne Credentials)
- Projekt-Konventionen und Regeln

#### Memory-Groesse

MEMORY.md darf max 200 Zeilen haben (danach wird abgeschnitten).
Fuer Details separate Topic-Dateien im gleichen Verzeichnis erstellen und aus MEMORY.md verlinken:

```markdown
## Detail-Thema
- Siehe [topic-name.md](topic-name.md) fuer Details
```

#### Dem User den vorgeschlagenen Memory-Eintrag zeigen

Den generierten/aktualisierten Memory-Eintrag dem User als Vorschlag zeigen BEVOR er geschrieben wird.
User muss bestaetigen oder anpassen koennen.
Erst nach Bestaetigung schreiben.

### Schritt 9: Deployment-Workflows erkennen und einrichten

**Hinweis:** Deploy-Workflows sind hochgradig projekt-spezifisch. Nutze die Erkennungslogik unten und erstelle deine eigenen Deploy-Skripte. Auf keinen Fall Credentials oder konkrete Server-IPs in Rules oder Skills hardcoden.

#### Deploy-Erkennung
```bash
echo "=== Deployment-Erkennung ==="
ls deploy*.sh infrastructure/deploy/*.sh scripts/deploy*.sh 2>/dev/null && echo "  Deploy-Scripts erkannt"
grep -ril "hetzner\|hcloud" .env* infrastructure/ scripts/ 2>/dev/null | head -1 > /dev/null && echo "  Hetzner erkannt"
grep -ril "proxmox\|pve" infrastructure/ scripts/ CLAUDE.md 2>/dev/null | head -1 > /dev/null && echo "  Proxmox erkannt"
grep -ril "coolify" .env* infrastructure/ 2>/dev/null | head -1 > /dev/null && echo "  Coolify erkannt"
ls infrastructure/customers/*.yml 2>/dev/null && echo "  Multi-Tenant (SaaS) erkannt"
```

#### Wenn Deploy erkannt:
1. **Deploy-Agent erstellen** (`.claude/agents/deploy-agent.md`) wenn noch nicht vorhanden
2. **Deploy-Rules erstellen** (`.claude/rules/deployment.md`) wenn noch nicht vorhanden
3. **Credential-Quellen dokumentieren** (in Memory, OHNE die Credentials selbst)
4. **Loop-Vorschlaege** fuer Post-Deploy-Monitoring in Memory dokumentieren

#### Credential-Handling (WICHTIG)
- Credentials aus bestehenden Quellen LESEN: `~/.git-credentials`, `~/.ssh/config`, `secrets/`, `.env`, `CLAUDE-NOTES.md`
- NIEMALS Credentials im Plugin, Memory oder Rules speichern
- NUR Credential-QUELLEN dokumentieren (z.B. "DB-Passwort: siehe secrets/postgres_password.txt")

#### Loop-Vorschlaege
Basierend auf erkannten Services dem User nuetzliche `/loop`-Befehle vorschlagen:

```
# Health-Check (immer wenn Services erkannt)
/loop 2m check health of all services

# Post-Deploy (wenn Deploy-Scripts erkannt)
/loop 30s verify production health after deploy

# Log-Monitoring
/loop 1m check logs for errors
```

### Schritt 10: Code-Review & Code-Quality einrichten

**Hinweis:** Dateigroessen-Limits findest du in `claude-code-workflow/rules/file-size-limits.md`, Code-Quality-Patterns in `claude-code-workflow/rules/code-quality-patterns.md`. Beide direkt nach `~/.claude/rules/` uebernehmbar.

#### Anthropic Code-Review (ersetzt CodeRabbit)

Offizielle Tools von Anthropic - IMMER einrichten:

1. **Skill erstellen** (`.claude/skills/claude-code-review/SKILL.md`) mit:
   - `/code-review` Plugin-Nutzung (mehrere parallele Review-Agenten)
   - `/security-review` fuer Security-Analyse
   - GitHub Actions Templates (`claude-code-action`, `claude-code-security-review`)

2. **GitHub Actions** (wenn .github/ existiert und GitHub als Host):
   - `.github/workflows/claude-review.yml` - automatisches PR-Review
   - `.github/workflows/claude-security.yml` - automatische Security-Analyse

3. **Gitea Actions** (wenn Gitea als Host erkannt):
   - `.gitea/workflows/ci.yml` - CI Pipeline (TypeScript-Check, Build, Python Syntax)
   - `.gitea/workflows/claude-review.yml` - Claude Review via `markwylde/claude-code-gitea-action@v1.0.5`
   - Secrets: `ANTHROPIC_API_KEY` + `GIT_ACCESS_TOKEN` (repo read/write, GITEA_TOKEN ist reserviert)
   - **Kostenkontrolle:** `max_turns: 3`, `timeout_minutes: 10`, `model: claude-haiku-4-5-20251001` (fuer Review-Runs das schnelle Haiku 4.5; bei inhaltlich groesseren Reviews auf `claude-sonnet-4-6` wechseln)
   - Nur bei `@claude` Trigger in PR-Kommentaren (kein Auto-Review)

#### Code-Quality Hooks

Basierend auf erkanntem Stack automatisch Hooks hinzufuegen:

**TypeScript/React Groessen-Check + any-Type Detection:**
```json
{
  "matcher": {
    "event": "tool_use",
    "tool_name": "Write",
    "file_paths": ["**/*.tsx", "**/*.ts", "**/*.jsx"]
  },
  "hooks": [{
    "type": "command",
    "command": "bash -c 'FILE=\"$CLAUDE_FILE_PATH\"; if [ -f \"$FILE\" ]; then LINES=$(wc -l < \"$FILE\"); LIMIT=300; echo \"$FILE\" | grep -qE \"\\\\.(ts|js)$\" && LIMIT=500; if [ $LINES -gt $LIMIT ]; then echo \"WARNUNG: $FILE hat $LINES Zeilen (max $LIMIT)\"; fi; if grep -Pn \"\\\\bany\\\\b\" \"$FILE\" 2>/dev/null | grep -v \"//.*any\\\\|test\\\\|spec\\\\|\\\\.d\\\\.ts\" | head -3; then echo \"WARNUNG: TypeScript any-Type gefunden - strikte Typen verwenden!\"; fi; fi'"
  }]
}
```

#### Entscheidungsmatrix Code-Review

| Erkannt | Was wird erstellt |
|---------|------------------|
| **Jedes Projekt** | claude-code-review Skill, Secret-Detection Hook |
| + Python | Python-Groessen-Hook (500 Zeilen), Raw SQL Check |
| + TypeScript/React | TS-Groessen-Hook (300/500 Zeilen), any-Type Check |
| + .github/ Verzeichnis (GitHub) | claude-review.yml + claude-security.yml Actions |
| + .gitea/ oder Gitea-Host erkannt | ci.yml + claude-review.yml (markwylde/claude-code-gitea-action) |
| + GitLab (kein GitHub/Gitea) | Nur lokale /code-review + /security-review |

### Schritt 11: Verifikation

```bash
echo "=== Verifikation ==="

# Struktur
echo "--- .claude/ Struktur ---"
find .claude -type f 2>/dev/null | sort

# JSON validieren
echo "--- JSON Validierung ---"
[ -f .mcp.json ] && (python3 -m json.tool .mcp.json > /dev/null 2>&1 && echo ".mcp.json: OK" || echo ".mcp.json: FEHLER")
[ -f .claude/hooks.json ] && (python3 -m json.tool .claude/hooks.json > /dev/null 2>&1 && echo "hooks.json: OK" || echo "hooks.json: FEHLER")

# Agenten zaehlen
echo "--- Agenten ---"
ls .claude/agents/*.md 2>/dev/null | wc -l
ls .claude/agents/*.md 2>/dev/null

# Memory pruefen
echo "--- Memory ---"
PROJECT_PATH=$(pwd)
MEMORY_DIR="$HOME/.claude/projects/$(echo $PROJECT_PATH | sed 's|/|-|g' | sed 's|^-||')/memory"
[ -f "$MEMORY_DIR/MEMORY.md" ] && echo "MEMORY.md: $(wc -l < "$MEMORY_DIR/MEMORY.md") Zeilen" || echo "MEMORY.md: nicht erstellt"

# LSP Smoke Test
echo "--- LSP Test ---"
# LSP documentSymbol auf eine erkannte Haupt-Datei ausfuehren
# LSP hover auf einen Import ausfuehren
```

### Schritt 11: Ergebnis-Zusammenfassung

Dem User eine Tabelle zeigen mit Status pro Komponente:

| Komponente | Status | Details |
|------------|--------|---------|
| LSP | [bereits vorhanden / neu installiert] | [welche Server] |
| Rules | [X bestehend + Y neu erstellt] | [Liste] |
| Hooks | [X bestehend + Y neu erstellt] | [Liste] |
| MCP Server | [X bestehend + Y neu hinzugefuegt] | [Liste] |
| Agenten | [X bestehend + Y neu erstellt] | [Liste mit Farben] |
| Memory | [neu erstellt / aktualisiert / bereits aktuell] | [Zeilen, Detail-Dateien] |
| Deployment | [erkannt / nicht erkannt] | [Scripts, Server, Credential-Quellen] |
| Code-Review | [eingerichtet / nicht eingerichtet] | [Skill, GitHub Actions, Hooks] |
| Loop-Vorschlaege | [X Vorschlaege] | [Health-Check, Deploy-Monitor, etc.] |

**Hinweise:**
- Hooks und neue Rules greifen ab der naechsten Session
- MCP Server muessen in den Settings aktiviert werden (enableAllProjectMcpServers oder einzeln)
- Agenten sind sofort verfuegbar
- Memory ist sofort in der naechsten Session verfuegbar
- Loop-Befehle: jederzeit mit `/loop [interval] [befehl]` starten
- Bei Problemen: `claude mcp list` zeigt aktive MCP Server

**Weiterempfehlung:**
- `/claude-features-update` ausfuehren um weitere Automatisierungen zu entdecken
