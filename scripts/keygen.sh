#!/usr/bin/env bash
# https://www.scottbrady91.com/OpenSSL/Creating-Elliptical-Curve-Keys-using-OpenSSL
set -euo pipefail

# Debug info
openssl ecparam -list_curves

# Create Keys

# Private Key
openssl ecparam -name secp521r1 -genkey -param_enc explicit -out private-key.pem

# Public Key
openssl ec -in private-key.pem -pubout -out public-key.pem

# Self-signed certificate
openssl req -new -x509 -key private-key.pem -out cert.pem -days 360

# PFX
openssl pkcs12 -export -inkey private-key.pem -in cert.pem -out cert.pfx