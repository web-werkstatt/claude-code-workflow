---
name: dokumentenaustausch
description: Dokumentenaustausch zwischen User und Claude Code. Aktiviere bei "Dokument ablegen", "Screenshot analysieren", "PDF lesen", "Export speichern", "Datei im Austausch-Ordner", "dokumentenaustausch", "shared folder", "gemeinsamen Dokumenten Ordner", "gemeinsamer Ordner", "Zugriffsrechte", "als .md Datei", ".md Datei erstellen", "Einstellungen speichern", "Dokument speichern", "in Ordner speichern", "Report erstellen".
allowed-tools: Read, Write, Glob, Grep, Bash(ls:*), Bash(mkdir:*), Bash(find:*), Bash(chmod:*), Bash(chgrp:*)
---

# Dokumentenaustausch

## Uebersicht

Zentraler Ordner fuer Datei-Austausch zwischen User und Claude Code.

**Pfad:** Wert der Umgebungsvariable `SHARED_DOCS_DIR` (z.B. `~/shared-docs/` oder `/mnt/shared/docs/`). Setze die Variable einmalig in `~/.bashrc` oder per `.env`.

## Schnellstart

### Dateien im Ordner auflisten

```bash
ls -la "$SHARED_DOCS_DIR"
```

### Datei lesen

```bash
# Beliebige Datei lesen (inkl. Bilder, PDFs)
Read "$SHARED_DOCS_DIR/DATEINAME"
```

### Datei schreiben

```bash
# Export/Report speichern
Write "$SHARED_DOCS_DIR/DATEINAME.md"
```

## Ordnerstruktur

```
$SHARED_DOCS_DIR/
├── README.md                    # Dokumentation
├── CLAUDE-CODE-PROMPT.md        # Prompt fuer Kollegen
├── screenshots/                 # Screenshots zur Analyse
├── pdfs/                        # PDF-Dokumente
├── exports/                     # Von Claude generierte Dateien
└── temp/                        # Temporaere Arbeitsdateien
```

## Unterordner erstellen (bei Bedarf)

```bash
mkdir -p "$SHARED_DOCS_DIR/screenshots"
mkdir -p "$SHARED_DOCS_DIR/pdfs"
mkdir -p "$SHARED_DOCS_DIR/exports"
mkdir -p "$SHARED_DOCS_DIR/temp"
```

## Typische Workflows

### 1. User will Screenshot analysieren

1. User legt Screenshot ab: `$SHARED_DOCS_DIR/screenshot.png`
2. User sagt: "Analysiere den Screenshot"
3. Claude liest mit Read-Tool
4. Claude analysiert und antwortet

### 2. Claude will Report exportieren

1. Claude erstellt Report
2. Claude speichert: `$SHARED_DOCS_DIR/exports/report-YYYY-MM-DD.md`
3. Claude informiert User ueber Pfad

### 3. PDF-Analyse

1. User legt PDF ab: `$SHARED_DOCS_DIR/pdfs/dokument.pdf`
2. User sagt: "Lies das PDF im Austausch-Ordner"
3. Claude liest PDF mit Read-Tool
4. Claude extrahiert relevante Informationen

## Dateinamen-Konvention

Empfohlenes Format: `YYYY-MM-DD-beschreibung.ext`

Beispiele:
- `2026-01-18-fehler-screenshot.png`
- `2026-01-18-analyse-report.md`
- `2026-01-18-rechnung.pdf`

## Wichtige Hinweise

- **Projektuebergreifend** - Funktioniert in allen Projekten
- **Nicht Git-versioniert** - Dateien werden nicht committed
- **Regelmaessig aufraeumen** - Alte Dateien loeschen

## Unterstuetzte Dateitypen

| Typ | Beschreibung |
|-----|--------------|
| `.md` | Markdown-Dokumente |
| `.txt` | Text-Dateien |
| `.pdf` | PDF-Dokumente |
| `.png`, `.jpg`, `.webp` | Bilder/Screenshots |
| `.json`, `.yaml` | Daten-Dateien |
| `.csv` | Tabellen |

## Fehlerbehandlung

**Datei nicht gefunden:**
```bash
ls -la "$SHARED_DOCS_DIR"
```

**Berechtigung verweigert:**
```bash
chmod 644 "$SHARED_DOCS_DIR/DATEI"
```

## Verwandte Dokumentation

- `$SHARED_DOCS_DIR/README.md` (lege bei Bedarf eine eigene README an, die das Ablage-Schema und Aufraeum-Routinen festhaelt)
