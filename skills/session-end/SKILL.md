---
name: session-end
description: Use when ending a work session, when the user says "Session beenden", "fuer morgen", "Feierabend", "Session zusammenfassen", "was haben wir gemacht", "next-session aktualisieren" or "fuer naechste Session". Archives the session summary, updates next-session.md slim, commits changes; pushes only after explicit user confirmation.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git show:*), Bash(git rev-parse:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git remote:*), Bash(date:*), Bash(curl:*), Bash(grep:*), Bash(cat:*)
argument-hint: [optional session title]
---

# Session-End Skill — Session dokumentieren, committen, (optional) pushen

Ziel dieses Skills: eine saubere Abschluss-Routine fuer eine Arbeitssession.
Die Routine soll

- einen kompakten Handoff in `next-session.md` hinterlassen,
- die vollstaendige Session-Zusammenfassung ins Archiv schreiben (nicht
  in die Haupt-Handoff-Datei),
- alle relevanten Aenderungen committen,
- erst NACH ausdruecklicher Zustimmung pushen,
- Repo-lokale Schreib-Policies respektieren (MANUAL-/DASHBOARD-GENERATED-
  Bloecke, append-only-Regeln, projekt-spezifische Hinweise in `CLAUDE.md`
  und `AGENTS.md`).

## Wann aktivieren

Der Skill aktiviert sich, wenn der User sagt:

- "Session beenden"
- "fuer morgen" / "fuer naechste Session"
- "Feierabend"
- "Session zusammenfassen"
- "next-session aktualisieren"
- "was haben wir gemacht"

## Grundprinzipien

- `next-session.md` ist **operativer Kurz-Handoff**, kein Session-Log.
  Keine neuen `## Session {DATUM}`-Blöcke in diese Datei schreiben.
- Session-Details kommen in `next-session-archiv.md` bzw. das projekt-
  spezifische Archiv (z.B. `docs/next-session-archive-YYYY-Q.md`, wenn
  ein Projekt seine Archive nach Quartal organisiert).
- Lese-Reihenfolge und Prioritaetsregeln aus projekt-lokalen Dateien
  (`CLAUDE.md`, `AGENTS.md`, Sub-`CLAUDE.md`) immer respektieren. Wenn ein
  Projekt eine abweichende Handoff-Regel definiert (z.B. `NOW-next-critical-
  path.md` als primaere Prioritaetsdatei), diese uebernehmen.
- MANUAL-/DASHBOARD-GENERATED-Bloecke nicht ueberschreiben, ausser der Skill
  ist als `source` des Blocks ausgewiesen.
- Unmarkierter Text gilt als manuell und ist schreibgeschuetzt.
- Push ist kein Default. Immer nur, wenn der User ausdruecklich zustimmt
  oder dies explizit verlangt hat.

## Ablauf

### 1. Projekt-Root ermitteln

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

Falls kein Git-Repo: fragen, ob trotzdem weitergemacht werden soll.

### 2. Session-Aktivitaet erheben

```bash
git status -s
git log --oneline --since="12 hours ago"
git diff --stat HEAD~10..HEAD 2>/dev/null | tail -30
```

Aus dem Log + dem Status eine kurze Zusammenfassung bilden:

- welche Features / Fixes / Docs neu sind
- welche Dateien geaendert wurden
- offene Punkte (aus TODO, Tests, Logs)

### 3. Repo-Konventionen lesen

Pruefen auf projekt-lokale Regeln:

- `CLAUDE.md` im Repo-Root
- `AGENTS.md` im Repo-Root
- Sub-`CLAUDE.md` in relevanten Verzeichnissen (`sprints/`, `services/`,
  `routes/`)

Typische Signale:

- append-only-Regel fuer `next-session.md`
- MANUAL-/DASHBOARD-GENERATED-Block-Konvention
- Hinweis auf eine `NOW-next-critical-path.md` oder aehnliche operative
  Prioritaetsdatei
- Hinweis auf `next-session-archiv*.md` oder `docs/next-session-archive-*.md`

Der Skill respektiert diese Regeln, ohne manuell geschriebene Abschnitte
zu kuerzen oder umzuformulieren.

### 4. Archiv-Datei bestimmen und befuellen

Archiv-Zielort pruefen in dieser Reihenfolge:

1. `next-session-archiv.md` im Repo-Root
2. `docs/next-session-archive-*.md`
3. sonst neu anlegen: `next-session-archiv.md` im Repo-Root

Neueste Session zuerst einfuegen (oben in der Datei). Format:

```markdown
## Session {ISO-DATUM} — {Titel}

### Was erledigt wurde
- {Feature 1}
- {Feature 2}

### Git-Commits
```
{git log --oneline}
```

### Betroffene Dateien
| Datei | Aenderung |
|-------|-----------|
| ... | ... |

### Offene Punkte fuer naechste Session
- {TODO 1}
```

Alles, was aktuell in `next-session.md` als Session-Block steht und nicht
zum Kurz-Handoff gehoert (also saemtliche `## Session ...`, Sprint-
Historie, abgeschlossene Tasks), zuerst in die Archivdatei ueberfuehren.

### 5. `next-session.md` als schlanken Handoff aktualisieren

Nur die operativen Felder anpassen. Der Header am Anfang der Datei:

```markdown
> **Letzte Aktualisierung:** {DATUM}
> **Status:** {EIN_SATZ_STAND}
> **Naechste Aufgabe:** {NAECHSTE_AUFGABE}
```

Operative Abschnitte (sofern vorhanden):

- `## Was gilt jetzt` — aktueller Arbeitsstand, **kein** Verlaufstext
- `## Naechste Aufgaben` / `## NOW / NEXT / LATER` — offene Punkte
- `## Wie naechste Session starten` — Lese-Reihenfolge respektieren
- `## Operative Hinweise` — Service-Infos, Logs, Backup-Pfade

Nicht:

- keine neuen `## Session {DATUM}`-Bloecke anfuegen
- keine kompletten Diff-Listen oder Commit-Dumps in `next-session.md`

Wenn der Repo-Flow einen einzeiligen "Update {DATUM}"-Block in
`next-session.md` verlangt (manche Projekte nutzen dieses Muster fuer
Dashboard-Sync), darf ein knapper Block von max. 5 Zeilen angefuegt
werden, aber keine Langfassung.

### 6. Commit

Gezielt stagen. Nicht `git add -A`:

```bash
git add next-session.md next-session-archiv.md <geaenderte-Dateien>
```

Nicht stagen: `secrets/`, `.env*`, `*.pdf`, `node_modules/`, `.next/`,
`.astro/`, `.kilocode/`, Build-Artifacts.

Commit-Message:

```bash
git commit -m "$(cat <<'EOF'
docs: Session {DATUM} dokumentiert

- {Haupt-Aenderung 1}
- {Haupt-Aenderung 2}

Co-Authored-By: Claude Code <noreply@anthropic.com>
EOF
)"
```

Co-Author-Zeile ohne Modell-Versions-Hardcoding, damit sie ueber mehrere
Model-Generationen stabil bleibt.

### 7. App-Sync — Summary und Next Step in die Datenbank schreiben (optional, projekt-spezifisch)

Dieser Schritt ist nur sinnvoll, wenn das Projekt eine eigene Status-/
Session-API betreibt, die Summary und Next-Step entgegennimmt
(`POST /api/sessions/{id}/summary` und `POST /api/sessions/{id}/next-step`).
Bei Projekten ohne solche API: diesen Schritt komplett ueberspringen.

Nur ausfuehren wenn im aktuellen Repo eine `docker-compose.yml` vorhanden ist
die auf einen App-Container hinweist (Stichwort `uvicorn` oder Port-Mapping
`XXXX:8000`) UND das Projekt eine `/api/sessions`-Route bereitstellt.

**7a. App-URL ermitteln**

```bash
grep -A3 "ports:" docker-compose.yml 2>/dev/null | grep -oP '\d+(?=:8000)'
```

Gefundener Host-Port ergibt `APP_URL=http://localhost:<PORT>`.
Kein Port gefunden → `APP_URL=http://localhost:8000`.

**7b. project\_key ermitteln**

Reihenfolge:
1. `.env` nach `PROJECT_KEY=` durchsuchen
2. Argument des Skill-Aufrufs falls angegeben
3. Fallback: `default`

**7c. Aktive Session ermitteln**

```bash
curl -sf "${APP_URL}/api/sessions?project_key=${PROJECT_KEY}"
```

Aus dem JSON-Array die neueste Session nehmen bei der `status != "archived"`
ist (erstes Element, da nach `updated_at desc` sortiert). Session-`id`
merken.

Schlaegt `curl` fehl (App nicht erreichbar, Exit-Code != 0) → Schritt
ueberspringen, im Output vermerken: "App nicht erreichbar — kein DB-Sync."

**7d. Summary schreiben**

Summary = ein kompakter Satz/Absatz was in dieser Session erledigt wurde
(aus Schritt 2 bereits bekannt).

```bash
curl -sf -X POST "${APP_URL}/api/sessions/${SESSION_ID}/summary" \
  -H "Content-Type: application/json" \
  -d "{\"summary\": \"${SUMMARY_TEXT}\"}"
```

**7e. Next Step schreiben**

Next Step = das wichtigste offene TODO fuer die naechste Session
(aus Schritt 5 `next-session.md` Abschnitt NOW/NEXT bereits bekannt).

```bash
curl -sf -X POST "${APP_URL}/api/sessions/${SESSION_ID}/next-step" \
  -H "Content-Type: application/json" \
  -d "{\"next_step\": \"${NEXT_STEP_TEXT}\"}"
```

Schlaegt ein Call fehl → Fehler im Output nennen, aber Ablauf nicht
abbrechen.

### 8. Push — nur nach Rueckfrage

**Niemals automatisch pushen.** Stattdessen:

1. Aktuellen Remote-Stand melden:
   ```bash
   git remote -v
   git status -b -s
   ```
2. Dem User berichten, dass der Commit lokal erstellt ist und fragen,
   ob gepusht werden soll (welcher Remote).
3. Erst nach expliziter Zustimmung:
   ```bash
   git push <remote> <branch>
   ```

Wenn der User zuvor in dieser Session pauschal "immer pushen" gesagt hat,
darf gepusht werden — sonst nicht.

## Ausgabe

Nach Abschluss:

```
Session dokumentiert.

Archiv:   <archiv-dateiname>
Handoff:  next-session.md aktualisiert
Datum:    {DATUM}
Commits:  {ANZAHL}
App-Sync: Session {ID} — Summary + Next Step geschrieben  ← neu
          (oder: App nicht erreichbar — kein DB-Sync)
Push:     offen (Rueckfrage an User)

Zusammenfassung:
- {Feature 1}
- {Feature 2}

Naechste Session:
- {TODO 1}
- {TODO 2}
```

## Hinweise

- `next-session.md` schlank halten. Ziel: max. 130 Zeilen nach
  Archivierung. Alles darueber hinaus: ins Archiv.
- Projekt-Konventionen haben Vorrang vor den Default-Pfaden in diesem
  Skill. Wenn das Repo z.B. eigenes Archiv unter `docs/` pflegt, dieses
  nutzen.
- Keine sensiblen Daten committen.
- Bei unfertigen Features Status "IN ARBEIT" in der Aufgaben-Liste
  setzen, nicht als "done" in der Status-Tabelle.
- Wenn ein Projekt eine Prioritaetsdatei wie `NOW-next-critical-path.md`
  pflegt, vor dem Handoff-Update pruefen, ob dort Anpassungen noetig
  sind (z.B. abgeschlossene NOW-Punkte ruecken nach NEXT nach).
