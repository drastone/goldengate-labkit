#!/bin/bash
## Copyright (c) 2021, Oracle and/or its affiliates.
set -e

CERT=$1
KEY=$2

##
##  c r e a t e _ c e r t i f i c a t e
##  Create a self-signed certificate/key pair
##
function create_certificate() {
    local config
    config="$(mktemp)"
    cat<<EOF > "${config}"
[req]
distinguished_name = distinguished_name
x509_extensions    = x509_extensions
prompt             = no

[distinguished_name]
CN                 = GoldenGate Deployment

[x509_extensions]
extendedKeyUsage   = serverAuth
EOF
    mkdir -p "$(dirname "${CERT}")"
    openssl req -x509 -sha256                              \
            -newkey rsa:2048 -nodes -keyout "${KEY}"  \
            -days $((365 * 3))      -out    "${CERT}" \
            -config "${config}"
    rm "${config}"
}

create_certificate
