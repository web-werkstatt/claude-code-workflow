# Branchen-Kriterienkataloge

Fallback-Kataloge, falls der User keinen mitliefert und WebFetch/WebSearch nicht verfügbar ist. Pro Branche: MVP-Kriterien (für funktionsfähiges System) und Produktreife-Kriterien (für gut wartbares System).

---

## Headless CMS

### MVP

| Bereich | Kriterium |
|---|---|
| Content | Strukturierte Content-Typen (Page, Article, Category, Author) |
| Content | Feldtypen (Text, Rich Text, Boolean, Number, Date, Media, Relation) |
| Content | Validierungen (required, unique, min/max, slug) |
| API | Öffentliche oder authentifizierte Content-API |
| API | Filter, Pagination, Sorting, Relationen |
| API | Schreib-/Management-API oder Admin-Backend |
| Editorial | Admin-Oberfläche |
| Editorial | Draft/Publish-Status |
| Editorial | Vorschau/Preview |
| Media | Upload und Verwaltung |
| Security | Rollen (Admin/Editor/Viewer) |
| Ops | Reproduzierbarer Build/Deploy-Prozess |

### Produktreife

| Bereich | Kriterium |
|---|---|
| Content | Komponenten/Blocks (wiederverwendbare Module) |
| Content | Taxonomien/Tags/Kategorien |
| Content | Mehrsprachigkeit/Locales |
| Editorial | Versionierung mit Änderungsverlauf |
| Editorial | Review-/Freigabeprozess |
| Editorial | Geplante Veröffentlichung |
| API | Webhooks für Rebuild/Cache |
| API | OpenAPI/Schema-Dokumentation |
| Security | API-Auth getrennt von Admin-Auth |
| Ops | Dev/Staging/Prod-Umgebungen |
| Ops | Migrationen für Schema |
| Ops | Backups/Restore |
| Wartung | Tests für Kernpfade |
| Wartung | CI/CD |
| Wartung | Geregelte Dependency-Updates |

### Stufe 2 (Roadmap)

- Visuelles Editing
- Content Releases/Kampagnen
- Granulare Rollen (auf Feldebene oder pro Space)
- Audit Logs
- Externe Suche/Indexierung
- Personalisierung
- AI-gestützte Redaktion

---

## E-Commerce

### MVP

- Produktkatalog mit Varianten
- Warenkorb + Checkout
- Zahlungsanbieter-Integration (mind. einer)
- Bestell-Bestätigung per E-Mail
- Admin-Backend für Bestellverwaltung
- Lager-/Bestandsverwaltung (mind. boolean „verfügbar")
- HTTPS + DSGVO-konforme Datenverarbeitung
- Produkt-Suche

### Produktreife

- Mehrere Zahlungsanbieter
- Versand-Optionen mit Tarif-Logik
- Rabatte/Gutscheine
- Steuerberechnung pro Region
- Retouren-Workflow
- Produkt-Reviews
- Wishlists / Merkzettel
- Kunden-Konten + Bestellhistorie
- Webhook-Integrationen (ERP, Versand, Buchhaltung)
- Admin-Auth-MFA
- PCI-DSS-konforme Karten-Verarbeitung
- Backups
- Tests + CI/CD

### Stufe 2

- Mehrsprachigkeit + Multi-Currency
- B2B-Funktionen (Preislisten, Rechnung, Net-Terms)
- Subscription-Produkte
- Marketplace / Multi-Vendor
- AI-Empfehlungen
- A/B-Testing

---

## SaaS / Web-App

### MVP

- User-Registrierung + Login
- Passwort-Reset-Flow
- Hauptfunktion (das, was die App tut) funktional
- Admin-Backend (mindestens User-Verwaltung)
- Daten-Persistenz mit Backup
- HTTPS
- Rechtliche Seiten (Impressum, Datenschutz, AGB)
- Reproduzierbarer Build/Deploy

### Produktreife

- Mehrstufige Auth (E-Mail-Verifikation, MFA optional)
- Rollen und Permissions
- Audit-Log relevanter Aktionen
- Rate-Limiting
- Logging + Monitoring
- Error-Tracking (Sentry o. Ä.)
- Health-Endpoint
- Tests für Kernpfade
- CI/CD
- Dependency-Update-Routine
- Onboarding-Flow für neue Nutzer
- Self-Service-Account-Verwaltung
- Daten-Export für Nutzer (DSGVO Art. 20)

### Stufe 2

- Tenant-Isolation für Multi-Tenancy
- SSO (SAML, OAuth)
- Webhooks
- API für externe Integration
- Internationalisierung
- Feature-Flags
- A/B-Testing

---

## API-Plattform

### MVP

- Authentifizierung (API-Keys oder OAuth)
- Rate-Limiting
- API-Versionierung-Strategie definiert
- Dokumentation (OpenAPI/Swagger)
- Konsistente Fehler-Responses
- HTTPS
- Logging der Requests

### Produktreife

- Pagination, Filter, Sorting standardisiert
- Webhooks
- SDK in mindestens einer Sprache
- Quotas pro Kunde/Plan
- Status-Page mit Uptime
- Deprecation-Policy
- Tests + CI/CD
- Backups

### Stufe 2

- GraphQL-Layer zusätzlich
- gRPC-Support
- Multi-Region-Deployment
- WebSocket/SSE für Real-Time
- API-Marketplace / Partner-Programm

---

## Mobile App (iOS/Android)

### MVP

- App startet und navigiert ohne Crash
- Login + Hauptfunktion funktional
- Offline-Verhalten definiert (mind. Cached-Read)
- App-Icon + Splash-Screen
- Datenschutz-Erklärung (Pflicht für Stores)
- Build-Pipeline für TestFlight / Internal Testing
- Crash-Reporting (Sentry, Crashlytics)

### Produktreife

- Push-Notifications
- Deep-Linking
- Biometric Auth (Face/Touch ID)
- Lokalisierung
- Accessibility (VoiceOver, TalkBack)
- Analytics
- Versionsupgrade-Strategie (Force-Update bei Breaking Changes)
- Backend-API mit graceful Degradation
- E2E-Tests (mind. Login + Hauptflow)
- CI/CD inkl. App-Store-Build

### Stufe 2

- Universal Links / App Clips / Instant App
- Offline-First-Architektur
- Hintergrund-Synchronisation
- Wear OS / Watch-Companion
- AR/Camera-Features
- AI-Features on-device

---

## Internes Tool / Internal Dashboard

### MVP

- Authentifizierung gegen Unternehmens-Identity (LDAP, SSO)
- Hauptansicht zeigt Daten korrekt
- Mindestens ein Schreib-Workflow (z. B. Status ändern)
- Daten kommen aus echter Quelle (kein Mock)
- Audit: wer hat was geändert
- Reproduzierbarer Deploy

### Produktreife

- Rollen pro Funktionsbereich
- Suche und Filter
- Export (CSV/Excel)
- Logs für Fehlersuche
- Onboarding-Doku für neue Mitarbeiter
- Backup der DB
- Tests für kritische Workflows

### Stufe 2

- Dashboards mit KPIs
- Workflow-Engine
- E-Mail-Reports automatisiert
- Integration mit Ticket-System
- Mobile-optimierte Ansicht

---

## Verwendung im Skill

1. User-Argument prüfen (`headless-cms`, `ecommerce`, `saas`, `api-platform`, `mobile-app`, `internal-tool`)
2. Wenn nicht angegeben: User fragen
3. Wenn anderer Typ: User um eigenen Katalog bitten oder generischen Mix aus den obigen ableiten
4. Pro Kriterium **immer** Beleg im Code suchen (Datei + Zeile), bevor Status gesetzt wird
5. Bei Unsicherheit: lieber „Teilweise" mit konkreter Lücke als „Ja"
