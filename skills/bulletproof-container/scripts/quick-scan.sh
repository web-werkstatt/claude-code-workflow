#!/bin/bash
# Quick Container Security Scan
# Usage: quick-scan.sh IMAGE:TAG

set -e

IMAGE="${1:-}"

if [ -z "$IMAGE" ]; then
    echo "Usage: $0 IMAGE:TAG"
    echo ""
    echo "Beispiele:"
    echo "  $0 nginx:latest"
    echo "  $0 wordpress:6.7-php8.4"
    echo "  $0 my-app:1.0.0"
    exit 1
fi

echo "============================================"
echo "BULLETPROOF CONTAINER SCAN"
echo "Image: $IMAGE"
echo "Datum: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================"
echo ""

# Check if Trivy is available
if command -v trivy &> /dev/null; then
    echo "[1/3] Trivy Vulnerability Scan..."
    echo "--------------------------------------------"
    trivy image --severity HIGH,CRITICAL "$IMAGE" 2>/dev/null || \
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy:latest image --severity HIGH,CRITICAL "$IMAGE"
    echo ""
else
    echo "[1/3] Trivy Scan (via Docker)..."
    echo "--------------------------------------------"
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy:latest image --severity HIGH,CRITICAL "$IMAGE"
    echo ""
fi

# Check if Grype is available
if command -v grype &> /dev/null; then
    echo "[2/3] Grype Vulnerability Scan..."
    echo "--------------------------------------------"
    grype "$IMAGE" --only-fixed 2>/dev/null | head -50
    echo ""
else
    echo "[2/3] Grype Scan (via Docker)..."
    echo "--------------------------------------------"
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        anchore/grype:latest "$IMAGE" --only-fixed 2>/dev/null | head -50
    echo ""
fi

# SBOM Generation
echo "[3/3] SBOM Generierung..."
echo "--------------------------------------------"
if command -v syft &> /dev/null; then
    syft "$IMAGE" -o table 2>/dev/null | head -30
else
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        anchore/syft:latest "$IMAGE" -o table 2>/dev/null | head -30
fi

echo ""
echo "============================================"
echo "SCAN ABGESCHLOSSEN"
echo "============================================"
echo ""
echo "Naechste Schritte:"
echo "  1. Kritische Vulnerabilities beheben"
echo "  2. Base-Image aktualisieren"
echo "  3. Unnoetige Pakete entfernen"
echo "  4. Non-root User verwenden"
