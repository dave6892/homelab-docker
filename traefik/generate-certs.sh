#!/bin/bash
# Generate self-signed SSL certificate for homelab services

set -e

CERT_DIR="$(dirname "$0")/certs"
CERT_FILE="$CERT_DIR/homelab.crt"
KEY_FILE="$CERT_DIR/homelab.key"

# Create certs directory if it doesn't exist
mkdir -p "$CERT_DIR"

# Check if certificates already exist
if [ -f "$CERT_FILE" ] && [ -f "$KEY_FILE" ]; then
    echo "Certificates already exist in $CERT_DIR"
    echo "To regenerate, delete the existing files and run this script again."
    exit 0
fi

echo "Generating self-signed certificate for homelab..."
echo ""

# Generate certificate with Subject Alternative Names (SAN) for all domains
openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE" \
    -subj "/CN=homelab.home/O=Homelab/C=US" \
    -addext "subjectAltName=DNS:homepage.home,DNS:plex.home,DNS:tautulli.home,DNS:pihole.home,DNS:*.home,DNS:localhost"

echo ""
echo "✓ Certificate generated successfully!"
echo "  Certificate: $CERT_FILE"
echo "  Private Key: $KEY_FILE"
echo "  Valid for: 10 years"
echo ""
echo "Next steps:"
echo "1. Install the certificate in your browser/system:"
echo "   - macOS: Open $CERT_FILE and add to Keychain, then trust it"
echo "   - Linux: Copy to /usr/local/share/ca-certificates/ and run update-ca-certificates"
echo "   - Windows: Double-click $CERT_FILE and install to Trusted Root"
echo ""
echo "2. Start/restart Traefik:"
echo "   docker-compose up -d"
echo ""
