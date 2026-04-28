# Dateigroessen-Limits (Global)

BEVOR du Code an eine bestehende Datei anhaengst, pruefe die aktuelle Zeilenzahl.
Wenn eine Datei das Limit ueberschreitet, MUSS sie aufgeteilt werden.

| Dateityp | Max Zeilen | Aktion bei Ueberschreitung |
|---|---|---|
| Python (.py) | 500 | In Module aufteilen (services/, utils/, models/) |
| React/TSX (.tsx, .jsx) | 300 | Komponenten extrahieren |
| TypeScript/JS (.ts, .js) | 500 | In Module aufteilen |
| CSS (.css) | 400 | In thematische Dateien aufteilen, per @import einbinden |
| SCSS (.scss) | 400 | In Partials aufteilen (_header.scss, _hero.scss) |
| HTML (.html, .astro) | 300 | Komponenten/Partials extrahieren |

## Workflow bei Ueberschreitung

1. STOPP - nicht einfach weiter anhaengen
2. User informieren: "Datei X hat Y Zeilen (Limit: Z). Ich teile sie auf."
3. Sinnvolle thematische Aufteilung vorschlagen
4. Nach Bestaetigung aufteilen und Imports anpassen

## CSS-Aufteilung Muster

```
styles/
  global.css          # @import + CSS Variablen (max 50 Zeilen)
  base.css            # Reset, Typography, Body
  components.css      # Wiederverwendbare Komponenten
  layout.css          # Grid, Container, Sections
  [feature].css       # Feature-spezifische Styles
```

## Praevention

- NIEMALS "am Ende anfuegen" als Default-Strategie
- Bei neuen Features: eigene Datei erstellen, nicht bestehende aufblaehen
- Vor jedem Write/Edit: mentale Pruefung "Wird diese Datei zu gross?"
- **Neue Dateien:** Wenn absehbar > 400 Zeilen, von Anfang an modular aufteilen (Unterverzeichnis mit Modulen)
- Schema-Dateien (`db_*_schema.py`) immer getrennt vom Service (`*_service.py`)

## Beim Pre-Commit-Hook-Fehler

Wenn ein Hook wegen Dateigroesse abbricht:

- **Niemals** `git commit --no-verify` nutzen
- **Niemals** willkuerliche Zeilen loeschen, um unter das Limit zu kommen
- **Niemals** Kommentare oder Blank Lines opfern
- Stattdessen: thematisch aufteilen, neue Module anlegen, Imports anpassen
- Die Aufteilung ist eigene Arbeit — **stopp, Vorschlag machen, auf Freigabe warten**
