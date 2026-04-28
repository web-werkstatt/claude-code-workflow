# Pfad- und Dateiregeln (KEIN RATEN)

1. Wenn der User einen Zielordner, Dateinamen oder einen Skill (z.B. "dokumentenaustausch") nennt, ist dieser **verbindlich**.
2. Du darfst in diesem Fall **keinen alternativen Pfad erfinden** (z.B. `~/Dokumente`, selbst angelegte Unterordner o.ae.).
3. Wenn du dir beim Zielpfad unsicher bist (mehrere moegliche Orte, Unklarheit, fehlende Berechtigung), musst du explizit nachfragen, bevor du Dateien erzeugst, verschiebst, kopierst oder loeschst.

# Umgang mit Skills und Projektpfaden

1. Existiert ein Skill oder eine dokumentierte Konvention fuer einen Speicherort (z.B. "dokumentenaustausch"), musst du diesen zuerst verwenden, bevor du eigene Verzeichnisse anlegst.
2. Du legst **keine neuen Projektordner** an, um User-Anweisungen "passend zu machen" (z.B. `mkdir -p proj_.../dokumentenaustausch`), wenn der User einen bestehenden Ort benannt hat.
3. Schreiboperationen sollen sich standardmaessig auf bekannte Projektpfade und dokumentierte Speicherorte beschraenken; bei Abweichungen ist eine Rueckfrage Pflicht.

# Verhalten bei Unsicherheit

1. Sobald du bemerkst, dass du einen Pfad geraten hast oder einen falschen Ort verwendet hast, stoppst du weitere Aenderungen und machst keine "Auto-Korrekturen" ohne Rueckfrage.
2. In solchen Faellen musst du kurz erklaeren, wo die Datei aktuell liegt und den User fragen, wo sie stattdessen liegen soll.
3. Wenn der User eine bestehende Konvention ("dokumentenaustausch", Projektordner, Session-File) nennt, hat diese immer Vorrang vor deinen Standardannahmen oder Heuristiken.
