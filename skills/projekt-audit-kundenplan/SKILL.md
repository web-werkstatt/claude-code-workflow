---
name: projekt-audit-kundenplan
description: Use when a customer project needs a structured audit, gap analysis, and a written delivery plan with milestones. Trigger phrases (DE) "Projekt prüfen für Kunden", "Fertigstellungsplan erstellen", "Bestandsaufnahme und Roadmap", "Audit und Sprint-Plan", "Kunde will Zeitplan", "Projekt fertigstellen Kunde". Trigger phrases (EN) "audit project for customer", "create completion plan", "customer roadmap". Produziert Prüfprotokoll, Sprint-Pläne, Fertigstellungsplan und Kunden-E-Mail.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(ls:*), Bash(find:*), Bash(cat:*), Bash(git log:*), Bash(git status:*), Agent
argument-hint: [branchen-katalog]
---

# Projekt-Audit + Kundenplan

Strukturierte Methodik, um ein bestehendes Kundenprojekt zu auditieren, mit dem Stand der Sprint-Planung abzugleichen und einen schriftlichen Fertigstellungsplan plus Kunden-E-Mail zu liefern. Funktioniert für jedes Projekt, das einen klaren Branchen-Kriterienkatalog hat (Headless CMS, E-Commerce, SaaS, Mobile App, etc.).

## Wann aktivieren

- "Projekt prüfen für Kunden"
- "Fertigstellungsplan erstellen"
- "Bestandsaufnahme und Roadmap"
- "Wir brauchen einen Plan für den Kunden"
- "Audit und Sprint-Plan"
- "Was fehlt noch bis zur Fertigstellung"
- explizit: `/projekt-audit-kundenplan [branchen-katalog]`

Beispiele für `branchen-katalog`: `headless-cms`, `ecommerce`, `saas`, `mobile-app`, `api-platform`, `internal-tool`. Wenn nicht angegeben: Nutzer fragen welche Branche das Projekt bedient.

## Voraussetzungen

- Git-Repository mit dem Projektcode
- Optional: bestehende Sprint-Pläne in `sessions/sprints/` oder `docs/`
- Optional: `CLAUDE.md`, `AGENTS.md`, oder Projekt-Doku
- Branchen-Kriterienkatalog (entweder mitgeliefert vom User oder vom Skill recherchiert)

## Ablauf

Der Skill arbeitet in **6 Phasen**, die sequenziell abgearbeitet werden. Nach jeder Phase wird ein Artefakt erzeugt und committet (oder als Diff vorgeschlagen).

### Phase 1 — Bestandsaufnahme (Read-only)

Ziel: Schnappschuss des Projekts ohne Änderungen.

- Repository-Struktur per `find` und `Glob` erfassen
- `package.json`, `pyproject.toml`, `requirements*.txt`, `Dockerfile*`, `docker-compose*.yml`, CI-Dateien lesen
- `CLAUDE.md`, `AGENTS.md`, `README.md` lesen
- Bestehende Sprint-Pläne in `sessions/sprints/` lesen (falls vorhanden)
- Letzte Commits ansehen (`git log -20 --oneline`)

Werkzeug der Wahl: **Agent mit subagent_type=Explore** für tiefe Codebasis-Erkundung. Spart Kontext im Hauptthread.

Output: keiner, nur Faktensammlung im Kontext.

### Phase 2 — Reproduzierbarkeits-Audit

Ziel: Prüfen ob Builds reproduzierbar sind. Das ist die universelle Grundlage für alle weiteren Schritte.

Prüfen pro Build-Einheit:

- npm: `npm install` vs. `npm ci`, Lockfile-Konsistenz, `engines`-Feld
- Python: `>=` vs. `==`, Lockfile vorhanden, Pinning-Strategie
- Docker: Multi-Stage, Base-Image-Pinning, Build-Reproduzierbarkeit
- Versions-Pins: `.nvmrc`, `.python-version`, `.tool-versions`
- CI/CD vorhanden?
- Dependency-Update-Routine vorhanden? (Renovate / Dependabot)

Output: **Befund-Tabelle** mit Status (Ja / Teilweise / Nein), Datei + Zeile, Risiko, Empfehlung.

Datei: `docs/reproduzierbarkeits-audit-YYYY-MM-DD.md`

### Phase 3 — Funktions-Audit gegen Branchen-Katalog

Ziel: Prüfen ob das Projekt die typischen Anforderungen seiner Branche erfüllt.

Quelle für Kriterienkatalog (in dieser Reihenfolge):
1. Vom User mitgelieferter Katalog (z. B. als Markdown-Tabelle im Prompt)
2. Branchenstandards recherchieren (WebFetch / WebSearch erlaubt, falls Tool verfügbar)
3. Generischer Katalog aus `references/branchen-kataloge.md` in diesem Skill

Bewertungsskala je Kriterium:
- **Ja** — vorhanden und brauchbar
- **Teilweise** — vorhanden, aber lückenhaft
- **Nein** — fehlt
- **Später** — bewusst nicht im Scope

Pflichtspalten in der Output-Tabelle:
- Bereich (Content / API / Editorial / Security / Ops / Wartung)
- Kriterium
- Status
- Beleg (Datei + Zeile oder Endpoint)
- Lücke (was konkret fehlt)

Output: **Prüfprotokoll** als Markdown-Tabelle.
Datei: `docs/<projekttyp>-pruefprotokoll-YYYY-MM-DD.md`

Plus eine **harte Selbstprüfung** mit 6–8 Ja/Nein-Fragen am Ende, die das Reifenniveau auf einen Blick zeigen.

### Phase 4 — Cross-Check gegen offene Sprints

Ziel: Lücken aus dem Prüfprotokoll mit existierenden Sprint-Plänen abgleichen.

Drei Befunde pro Sprint-Datei:
1. **Welche Lücken adressiert dieser Sprint?**
2. **Welche Doppelt-Definitionen gibt es?** (gleiches Thema in mehreren Sprints)
3. **Welche Lücken sind noch nicht abgedeckt?**

Output: **Cross-Check-Tabelle** mit drei Teilen:
- Teil A: Lücken-Mapping (Lücke → Sprint, mit Status: abgedeckt / mehrfach / fehlt)
- Teil B: Doppelt-Definitionen mit Konsolidierungs-Empfehlung
- Teil C: Echte Lücken (kein Sprint geplant) mit Prioritäts-Vorschlag

Datei: `docs/<projekttyp>-pruefprotokoll-sprint-crosscheck.md`

### Phase 5 — Sprint-Pläne für Lücken

Ziel: Für jede identifizierte echte Lücke einen umsetzbaren Sprint-Plan anlegen.

Pro Lücke:
- Eigener Sprint-Plan in `sessions/sprints/SPRINT_<THEMA>.md`
- Format konsistent mit existierenden Sprints im Projekt
- Pflicht-Sektionen: Ziel, Voraussetzung, Phasen mit Tasks, Definition of Done

Siehe `references/sprint-template.md` in diesem Skill für ein leeres Template.

**Wichtig:** Kein Auto-Anlegen ohne Rückfrage, wenn der User nur einen Sprint pro Sitzung will. Default: alle Lücken mit Status "Nein" werden als Sprint vorgeschlagen, der User bestätigt einzeln.

### Phase 6 — Kundenplan + E-Mail

Ziel: Die Audit-Ergebnisse für den Kunden aufbereiten.

#### 6a — Fertigstellungsplan

Datei: `docs/kunden-fertigstellungsplan-YYYY-MM-DD.md`

Pflicht-Sektionen:
- **Was ist „fertig"?** — klare Zielzustands-Definition
- **Phasen-Übersicht** als Tabelle (Phase, Sprint-Datei, Aufwand, Kalenderzeit)
- **Pro Phase:** Was wird gemacht, Aufwand, Ergebnis, Risiko
- **Meilensteine** mit Datum/Woche und sichtbarem Kundennutzen
- **Was nach der Fertigstellung kommt** (Roadmap-Items)
- **Risiken und Annahmen**
- **Reporting** — Format und Frequenz

Aufwand-Schätzungen sind realistisch, nicht optimistisch. Pufferzeit (15–25 %) explizit ausweisen.

#### 6b — Kunden-E-Mail

Datei: `docs/kunden-email-fertigstellungsplan.md`

Pflicht-Format:
- **Anrede in Du-Form** (sofern Kundenbeziehung dies zulässt — sonst Sie-Form)
- **Maximal 1 Bildschirmseite Lesedauer**
- **Faktisch, keine Marketing-Sprache** (keine Wörter wie "professionell", "innovativ", "best-of-breed")
- Aufbau:
  1. Wo wir stehen (1 Absatz, Reife-Prozent, was funktioniert, was fehlt)
  2. Plan-Tabelle (Wochen + Phase + sichtbares Ergebnis)
  3. Aufwand transparent (Tage, Wochen)
  4. Meilensteine (mit Hervorhebung des für den Kunden wichtigsten)
  5. Was vom Kunden gebraucht wird (mit Deadline)
  6. Was nach Fertigstellung kommt
  7. Risiken transparent
  8. Reporting-Frequenz
  9. Nächster Schritt + Call-to-Action

- **Platzhalter** für Kundenname/Vorname und Signatur sind klar markiert (`[Vorname]`, `[Dein Name]`)

Siehe `templates/kunden-email-template.md` in diesem Skill.

## Repo-Konventionen respektieren

- Bestehende `CLAUDE.md` / `AGENTS.md` / `next-session.md`-Regeln einhalten
- Append-only-Dateien nur ergänzen, nie überschreiben
- Bestehende Sprint-Datei-Naming-Konvention übernehmen (`SPRINT_<THEMA>.md` o. Ä.)
- Sprache der Codebasis spiegeln: deutsche Codebasis → deutsche Outputs
- Wenn `CLAUDE.md` Kommunikationsregeln vorgibt (z. B. „Nur Fakten, keine Marketing-Sprache"), strikt befolgen

## Update von next-session.md

Wenn das Projekt eine `next-session.md` hat: am Ende der Sitzung **append-only** ergänzen mit:
- Verweis auf alle erstellten Dokumente
- Übersicht der neuen Sprint-Pläne
- Empfehlung für nächsten Einstieg

Niemals bestehenden Inhalt löschen oder ersetzen — nur unten anhängen mit klarem Datums-Header.

## Destruktive Aktionen

Dieser Skill schreibt nur **neue** Dateien und ergänzt `next-session.md` (append-only). Es werden **keine** existierenden Dateien überschrieben.

Bei Konflikt (Datei existiert bereits): Rückfrage beim User, ob überschrieben, ergänzt oder unter neuem Namen gespeichert werden soll.

**Niemals automatisch:**
- `git commit` (User entscheidet)
- `git push` (User entscheidet)
- E-Mail tatsächlich senden (Skill liefert nur den Entwurf als Markdown)

## Hinweise

- Wenn das Projekt **noch keinen** Branchen-Kriterienkatalog hat: User nach den 5 wichtigsten Funktionen fragen, daraus einen Mini-Katalog ableiten. Lieber kleiner und präzise als generisch und groß.
- Bei sehr kleinen Projekten (< 1.000 Zeilen Code): Phasen 4 und 5 ggf. zusammenfassen.
- Bei sehr großen Monorepos: Phase 1 und 2 unbedingt mit Explore-Subagent fahren, sonst Kontext-Überlauf.
- Aufwand-Schätzungen werden **immer** als Spanne angegeben (`2–3 Tage`), nie als Punkt-Schätzung.
- Wenn der Kunde technisch nicht versiert ist: in der E-Mail keine Begriffe wie „CI/CD", „Lockfile", „Reproduzierbarkeit" verwenden — durch laienverständliche Formulierungen ersetzen („automatische Qualitätsprüfung", „identische Builds").

## Output-Übersicht

Nach vollständigem Durchlauf existieren folgende neue Dateien:

| Datei | Zweck |
|---|---|
| `docs/reproduzierbarkeits-audit-YYYY-MM-DD.md` | Build-Reproduzierbarkeits-Befund |
| `docs/<projekttyp>-pruefprotokoll-YYYY-MM-DD.md` | Funktions-Audit gegen Branchen-Katalog |
| `docs/<projekttyp>-pruefprotokoll-sprint-crosscheck.md` | Lücken-Mapping vs. existierende Sprints |
| `sessions/sprints/SPRINT_<THEMA>.md` (n Stück) | Sprint-Pläne für identifizierte Lücken |
| `docs/kunden-fertigstellungsplan-YYYY-MM-DD.md` | Detailplan für den Kunden |
| `docs/kunden-email-fertigstellungsplan.md` | E-Mail-Entwurf zum Versand |
| Update `next-session.md` | Append-only Hinweis auf alle obigen Dateien |

## Referenzen

- Sprint-Template: [templates/sprint-template.md](templates/sprint-template.md)
- E-Mail-Template: [templates/kunden-email-template.md](templates/kunden-email-template.md)
- Branchen-Kataloge (wenn extern nicht verfügbar): [templates/branchen-kataloge.md](templates/branchen-kataloge.md)
