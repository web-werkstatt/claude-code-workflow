# Kunden-E-Mail Template

Einsetzen für `docs/kunden-email-fertigstellungsplan.md` nach Phase 6 des Skills `projekt-audit-kundenplan`.

Platzhalter mit `[…]` müssen vor dem Versand ausgetauscht werden.

---

```markdown
# E-Mail an Kunde — Fertigstellungsplan <Projektname>

**Erstellt:** YYYY-MM-DD
**Empfänger:** [Kundenname]
**Betreff:** <Projektname> — Plan bis Fertigstellung (<N> Wochen, <M> Meilensteine)

---

Hallo [Vorname],

ich habe <Projektname> in den letzten Tagen vollständig geprüft und einen klaren Plan bis zur Fertigstellung erstellt. Hier die Kurzfassung — den Detailplan hänge ich separat an.

---

## Wo wir stehen

<1 Absatz: was funktioniert technisch bereits, ohne Marketing-Sprache. Konkrete Reife-Prozent-Angabe aus dem Prüfprotokoll, z. B. "63 % Produktreife".>

Was fehlt, sind <N> Bereiche:
1. **<Bereich 1>** — <was konkret>
2. **<Bereich 2>** — <was konkret>
3. **<Bereich 3>** — <was konkret>

<1 Satz: warum die Lücken adressierbar sind, ohne das Produkt umzubauen.>

---

## Der Plan: <N> Wochen, <M> Phasen

| Woche | Phase | Was du danach hast |
|---|---|---|
| 1 | <Phase 1> | <sichtbares Ergebnis> |
| 2 | <Phase 2> | <sichtbares Ergebnis> |
| … | … | … |

**Aufwand:** <X–Y> Entwicklertage netto, mit Reviews und Puffer realistisch <N> Kalenderwochen für einen Entwickler in Vollzeit.

---

## Meilensteine, die du sehen wirst

- **Ende Woche <N>:** <Meilenstein 1 — sichtbares Ergebnis>
- **Ende Woche <N>:** <Meilenstein 2>
- **Ende Woche <N>:** <Meilenstein 3>

Für dich am relevantesten ist **Meilenstein <N>** in Woche <N> — <warum dieser Meilenstein für den Kunden zentral ist>.

---

## Was ich von dir brauche

Damit Phase <N> in Woche <N–N> ohne Verzögerung läuft, brauche ich von dir bis spätestens **<Datum oder Wochenangabe>**:

- <konkrete Anforderung 1>
- <konkrete Anforderung 2>
- <konkrete Anforderung 3>

Wenn du früher liefern kannst, können wir Phase <N> vorziehen.

---

## Was nach der Fertigstellung kommt

Nicht in diesen <N> Wochen, aber im Backlog für später, falls relevant:
- <Roadmap-Item 1>
- <Roadmap-Item 2>
- <Roadmap-Item 3>

Diese Themen priorisieren wir nach deinem Feedback und Marktrückmeldung.

---

## Risiken — transparent

- <Risiko 1 mit Auswirkung und Gegenmaßnahme>
- <Risiko 2>
- <Risiko 3>

---

## Reporting

Du bekommst jeden <Wochentag> einen kurzen Statusbericht:
- erledigt seit letztem Bericht
- in Arbeit
- offene Punkte / Blocker
- nächster Meilenstein

Alle Pläne und Prüfprotokolle sind im Repo versioniert und für dich einsehbar.

---

## Nächster Schritt

Wenn du mit dem Plan einverstanden bist, starte ich <Wochenangabe> mit Phase 1 (<Phase-1-Name>).
Falls du einzelne Phasen anders priorisieren möchtest oder eine Phase rausnehmen willst, lass es mich wissen — das ist dein Plan.

Den vollständigen Plan mit allen Details findest du im Anhang (`kunden-fertigstellungsplan-YYYY-MM-DD.md`).

Bei Fragen ruf mich an oder schreib mir.

Beste Grüße
[Dein Name]

---

*Anhang: `kunden-fertigstellungsplan-YYYY-MM-DD.md`*
```

## Schreibregeln

1. **Du-Form** als Default; wenn Kundenbeziehung Sie-Form verlangt, alle Anreden ersetzen (auch implizite wie „du bekommst")
2. **Maximal 1 Bildschirmseite Lesedauer** — wenn länger, kürzen
3. **Keine Marketing-Sprache:** verboten sind Wörter wie „professionell", „innovativ", „state-of-the-art", „best-of-breed", „ganzheitlich", „nahtlos"
4. **Konkrete Zahlen** statt vager Begriffe: „11 Wochen" statt „einige Wochen", „63 %" statt „solide"
5. **Aufwand transparent** — Spannen statt Punktschätzungen
6. **Risiken benennen** — niemals beschönigen
7. **Was vom Kunden gebraucht wird** muss eine Deadline haben — sonst kommt es nicht
8. **Technische Begriffe** nur wenn der Kunde technisch ist; sonst übersetzen:
   - „CI/CD" → „automatische Qualitätsprüfung"
   - „Lockfile" → „festgeschriebene Versionen"
   - „Reproduzierbarkeit" → „identische Builds"
   - „Renovate/Dependabot" → „automatisierte Updates"
   - „Migration" → „Datenbankanpassung"
9. **Keine Emojis**
10. **Anhang explizit benennen** mit Dateipfad
