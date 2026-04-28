# Code Quality Patterns (Globale Regeln)

## Kein duplizierter Code

### Python
- **Error-Handling:** `@api_route` Decorator statt try/except in jedem Endpoint. Nur bei speziellen Fehler-Responses (Fallback-Daten) manuelles try/except.
- **SQL-Filter:** Wiederkehrende WHERE-Klausel-Builder als Helper extrahieren (`_build_X_filter()`), nicht in jedem Endpoint kopieren.
- **Shared Helpers:** Wenn zwei Module dieselbe Logik brauchen, in eine `_utils.py` Datei auslagern. NICHT Circular Imports erzeugen (Modul A importiert B das A importiert).
- **Timestamp-Parsing, NULL-Byte-Bereinigung, Datei-Hashing:** Einmal definieren, ueberall importieren.

### JavaScript
- **Utility-Funktionen** (formatTokens, formatDate, formatDateTime, escapeHtml) gehoeren in `base.js` oder eine zentrale `utils.js` die auf allen Seiten geladen wird. NIEMALS in einzelnen Seiten-JS-Dateien definieren.
- **Gleichnamige Funktionen** in verschiedenen JS-Dateien werden sich gegenseitig ueberschreiben. Wenn eine Funktion seitenspezifisch ist, einen eindeutigen Namen geben (z.B. `formatTimeAgo` statt `formatDate` fuer relative Zeiten).

### CSS
- **Wiederverwendbare Klassen** (.empty-state, .modal-overlay, .filter-pill) gehoeren in `components.css`. Nicht in Feature-spezifischen CSS-Dateien duplizieren.
- Wenn ein Component-Style angepasst werden muss, einen spezifischeren Selektor verwenden (`.plans-page .empty-state`) statt den Basis-Style zu kopieren.

## Session-Import / Datenbank

- **IMMER DELETE vor INSERT** bei Messages - verhindert Duplikate bei Re-Import.
- **Hash-basierter Cache** fuer Datei-Aenderungserkennung statt DB-Queries pro Datei.
- **PostgreSQL jsonb:** Content-JSON immer durch `json.loads()` -> `json.dumps(ensure_ascii=True)` normalisieren. `\u0000` Null-Bytes werden von PostgreSQL abgelehnt.
- **Kein Timer-basierter Sync** fuer Datenbank-Imports. On-demand mit Cooldown ist besser.

## Systemd-Services & Docker

- **restart: unless-stopped** bedeutet: Container startet nach jedem Reboot. Nur fuer Services die wirklich 24/7 laufen muessen.
- **--reload Flag** bei uvicorn/gunicorn nur waehrend aktiver Entwicklung, nicht in Production-Containern (verbraucht CPU durch File-Watcher).
- **Systemd-Timer:** Vor dem Erstellen pruefen ob die Aufgabe wirklich periodisch laufen muss. On-demand ist fast immer besser.
- **Docker Cleanup:** Regelmaessig `docker system prune` einplanen. Build-Cache und alte Images wachsen schnell auf hunderte GB.

## Dokumentation

- **CLAUDE.md** bei jeder Architektur-Aenderung aktualisieren (neue Services, neue Patterns, geaenderte Imports).
- **Neue Helper-Funktionen** und Shared Utilities in CLAUDE.md unter "Wichtige Patterns" dokumentieren, damit kuenftige Sessions sie wiederverwenden statt neu zu erfinden.
- **Sprint-Plaene** mit Ergebnis-Status aktualisieren wenn Tasks erledigt sind.

## Vor jedem Commit pruefen

1. Gibt es duplizierte Funktionen? -> Extrahieren
2. Gibt es verwaiste Imports/Dateien? -> Entfernen
3. Ist die CLAUDE.md aktuell? -> Updaten
4. Werden neue Patterns dokumentiert? -> Ja
