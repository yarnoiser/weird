#!/bin/sh

SSL_PATH='server/data/ssl'

# generate openssl key and self signed certificate
openssl genrsa -out "$SSL_PATH/key.pem" 2048
openssl req -new -sha256 -key "$SSL_PATH/key.pem" -out "$SSL_PATH/csr.csr"
openssl req -x509 -sha256 -days 365 -key "$SSL_PATH/key.pem" -in "$SSL_PATH/csr.csr" -out "$SSL_PATH/cert.pem"
openssl req -in "$SSL_PATH/csr.csr" -text -noout | grep -i "Signature.*SHA256" && echo "All is well" || echo "This certificate will stop working in 2017! You must update OpenSSL to generate a widely-compatible certificate"
