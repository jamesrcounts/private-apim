#!/usr/bin/env bash
set -euo pipefail

# Debug info
certbot --version

# Get certificates using Route53 for validation
certbot certonly --dns-route53 -d api.jamesrcounts.com