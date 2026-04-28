---
name: bulletproof-container
description: Container-Sicherheit und Haertung. Aktiviere bei "container sicherheit", "docker security", "image scannen", "vulnerability scan", "SBOM", "container haerten", "bulletproof", "security audit", "trivy", "grype".
allowed-tools: Bash, Read, Write, Glob, Grep, Task
---

# Bulletproof Container Security

## Uebersicht

Umfassende Container-Sicherheitsanalyse, Vulnerability-Scanning und Haertung.

## Agent starten (EMPFOHLEN)

Fuer umfassende Analysen den **container-security-agent** starten:

```
Bitte starte den container-security-agent fuer eine vollstaendige
Sicherheitsanalyse meiner Docker-Container.
```

Der Agent:
- Recherchiert aktuelle CVEs und Best Practices
- Installiert automatisch Trivy, Grype, Syft, Cosign
- Fuehrt Multi-Tool-Scans durch
- Generiert SBOM und signiert Images
- Erstellt gehaertete Konfigurationen

## Quick Actions

### 1. Starte Security-Agent

```
Starte den container-security-agent fuer umfassende Analyse
```

### 2. Schnell-Scan eines Images

```bash
# Mit Trivy (empfohlen)
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image IMAGE_NAME:TAG

# Mit Grype
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  anchore/grype:latest IMAGE_NAME:TAG
```

### 3. SBOM generieren (Software Bill of Materials)

```bash
# Mit Syft
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  anchore/syft:latest IMAGE_NAME:TAG -o json > sbom.json
```

## Security-Checkliste

### Image-Haertung

| Check | Beschreibung | Status |
|-------|--------------|--------|
| [ ] | Non-root User verwenden | |
| [ ] | Minimales Base-Image (alpine/distroless) | |
| [ ] | Keine Secrets im Image | |
| [ ] | Multi-Stage Build | |
| [ ] | Feste Image-Tags (keine :latest) | |
| [ ] | Read-only Filesystem | |
| [ ] | Keine unnötigen Pakete | |

### Runtime-Sicherheit

| Check | Beschreibung | Status |
|-------|--------------|--------|
| [ ] | Security Context gesetzt | |
| [ ] | Resource Limits definiert | |
| [ ] | Network Policies aktiv | |
| [ ] | Privileged: false | |
| [ ] | Capabilities gedroppt | |
| [ ] | Seccomp-Profil aktiv | |

### Docker Compose Haertung

```yaml
services:
  app:
    image: app:1.0.0  # Fester Tag, nicht :latest
    user: "1000:1000"  # Non-root
    read_only: true    # Read-only Filesystem
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE  # Nur was noetig
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 128M
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## Vulnerability-Scan Workflow

### Schritt 1: Image scannen

```bash
# Trivy - umfassender Scan
trivy image --severity HIGH,CRITICAL IMAGE:TAG

# Grype - schneller Scan
grype IMAGE:TAG

# Docker Scout (wenn verfuegbar)
docker scout cves IMAGE:TAG
```

### Schritt 2: Ergebnisse analysieren

```bash
# Trivy JSON-Report
trivy image -f json -o report.json IMAGE:TAG

# Nach Schweregrad filtern
cat report.json | jq '.Results[].Vulnerabilities[] | select(.Severity == "CRITICAL")'
```

### Schritt 3: Fixes anwenden

```dockerfile
# Base-Image aktualisieren
FROM alpine:3.19  # Neueste Version

# Pakete aktualisieren
RUN apk update && apk upgrade --no-cache

# Spezifische Fixes
RUN apk add --no-cache libcrypto3>=3.1.4-r0
```

## SBOM-Generierung

### Mit Syft

```bash
# CycloneDX Format (Standard)
syft IMAGE:TAG -o cyclonedx-json > sbom-cyclonedx.json

# SPDX Format
syft IMAGE:TAG -o spdx-json > sbom-spdx.json

# Tabellarische Ausgabe
syft IMAGE:TAG -o table
```

### SBOM analysieren

```bash
# Vulnerabilities aus SBOM
grype sbom:sbom-cyclonedx.json

# Lizenz-Check
syft IMAGE:TAG -o table | grep -E "(GPL|AGPL)"
```

## Dockerfile Best Practices

```dockerfile
# ============================================
# BULLETPROOF DOCKERFILE TEMPLATE
# ============================================

# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Stage 2: Production
FROM gcr.io/distroless/nodejs20-debian12

# Labels fuer Traceability
LABEL org.opencontainers.image.source="https://github.com/..."
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.created="2026-01-18"

# Non-root User (distroless hat bereits nonroot)
USER nonroot:nonroot

# Nur Production-Dateien
WORKDIR /app
COPY --from=builder --chown=nonroot:nonroot /app/dist ./dist
COPY --from=builder --chown=nonroot:nonroot /app/node_modules ./node_modules

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["/nodejs/bin/node", "-e", "require('http').get('http://localhost:3000/health')"]

# Expose nur noetige Ports
EXPOSE 3000

# Immutable CMD
CMD ["/nodejs/bin/node", "dist/main.js"]
```

## Tools Installation

### Trivy installieren

```bash
# Debian/Ubuntu
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update && sudo apt-get install trivy

# Oder via Docker
alias trivy="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest"
```

### Grype + Syft installieren

```bash
# Grype
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

# Syft
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Scan image with Trivy
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: '${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}'
    format: 'sarif'
    output: 'trivy-results.sarif'
    severity: 'CRITICAL,HIGH'

- name: Upload Trivy scan results
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: 'trivy-results.sarif'
```

## Notfall-Befehle

### Container sofort stoppen

```bash
docker stop $(docker ps -q)
```

### Verdaechtigen Container isolieren

```bash
docker network disconnect NETWORK CONTAINER
docker pause CONTAINER
```

### Forensik-Snapshot

```bash
docker export CONTAINER > forensic-snapshot.tar
docker logs CONTAINER > container-logs.txt 2>&1
docker inspect CONTAINER > container-inspect.json
```

## Agent starten

Um den vollstaendigen Security-Agenten zu starten:

```
Bitte starte den container-security-agent fuer eine umfassende
Sicherheitsanalyse aller Docker-Container und Images.
```

Der Agent fuehrt automatisch durch:
1. Image-Scanning mit Trivy/Grype
2. SBOM-Generierung
3. Vulnerability-Report
4. Haertungs-Empfehlungen
5. Runtime-Analyse
