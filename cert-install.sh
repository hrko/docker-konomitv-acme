#!/bin/sh

mkdir -p "/cert"

install -m 0644 "$LEGO_CERT_PATH"     "/cert/cert.pem"
install -m 0644 "$LEGO_CERT_KEY_PATH" "/cert/key.pem"

# restart konomitv
supervisord ctl stop konomitv
sleep 5
supervisord ctl start konomitv
