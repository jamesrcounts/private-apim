#!/usr/bin/env bash
set -euox pipefail

apt update
apt-get update
apt-get install -y certbot 
apt-get install -y python3-pip
pip3 install acme certbot-dns-route53 --upgrade