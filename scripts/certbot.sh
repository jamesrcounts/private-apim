#!/usr/bin/env bash
set -euo pipefail

# Debug info
certbot --version

# Get certificates using Route53 for validation
DOMAIN="api.jamesrcounts.com"
certbot certonly --dns-route53 -d ${DOMAIN}

# PFX
openssl pkcs12 -export -inkey /etc/letsencrypt/live/${DOMAIN}/privkey.pem -in /etc/letsencrypt/live/${DOMAIN}/cert.pem -out ${DOMAIN}.pfx