#!/usr/bin/env bash
set -euo pipefail

# Debug info
certbot --version

# Get certificates using Route53 for validation
DOMAIN="portal.jamesrcounts.com"
certbot certonly --dns-route53 -d ${DOMAIN}
mkdir -p ./certs/${DOMAIN}
cp -R /etc/letsencrypt/archive/${DOMAIN}/* ./certs/${DOMAIN}/