#!/usr/bin/bash

LEGO_GLOBAL_OPTS=(
  "--accept-tos"
  "--server"  "$LEGO_SERVER"
  "--path"    "$LEGO_PATH"
  "--email"   "$LEGO_EMAIL"
  "--dns"     "$LEGO_DNS_PROVIDER"
  "--domains" "$CERT_DOMAIN"
)

# if LEGO_EAB is set, add EAB options
if [ -n "$LEGO_EAB" ]; then
  LEGO_GLOBAL_OPTS+=("--eab")
  LEGO_GLOBAL_OPTS+=("--kid")
  LEGO_GLOBAL_OPTS+=("$LEGO_EAB_KID")
  LEGO_GLOBAL_OPTS+=("--hmac")
  LEGO_GLOBAL_OPTS+=("$LEGO_EAB_HMAC")
fi

_log() {
  type=$1
  message=$2
  date=$(date -Iseconds)
  echo "$date [$type] $message"
}

# sleep until next day of CERT_RENEWAL_TIME
sleep_until_nextday() {
  random_seconds=$((RANDOM % 3600))
  current_epoch=$(date +%s)
  target_epoch=$(date -d "$CERT_RENEWAL_TIME 1 day ${random_seconds} sec" +%s)
  sleep_seconds=$((target_epoch - current_epoch))
  target_date=$(date -d "@$target_epoch" -Iseconds)
  _log "INFO" "sleeping until $target_date ($sleep_seconds seconds)"
  sleep $sleep_seconds
}

renew_cert() {
  _log "INFO" "renewing cert"

  # note that acctual renewal is doneonly if cert's expiration date
  # is within 30 days. otherwise, lego will just exit with no error.
  /usr/local/bin/lego \
    "${LEGO_GLOBAL_OPTS[@]}" \
    renew \
    --renew-hook "/cert-install.sh"

  # if lego exited with non-zero exit code, exit
  if [ $? -ne 0 ]; then
    _log "ERROR" "lego exited with non-zero exit code"
    exit 1
  fi
}

lego_certificates_exist() {
  out=$(lego \
    --path "$LEGO_PATH" \
    list)

  if [ "$out" = "No certificates found." ]; then
    return 1 # failure if no certs exist
  else
    return 0 # success if certs exist
  fi
}

_init() {
  _log "INFO" "starting cert issuance/renewal service"

  # if cert exists, return
  if lego_certificates_exist; then
    _log "INFO" "cert exists, skipping issue"
    return 0
  else
    _log "INFO" "cert does not exist, issuing"
    /usr/local/bin/lego \
      "${LEGO_GLOBAL_OPTS[@]}" \
      run \
      --run-hook "/cert-install.sh"

    # if lego exited with non-zero exit code, exit
    if [ $? -ne 0 ]; then
      _log "ERROR" "lego exited with non-zero exit code"
      exit 1
    fi

    # if cert does not installed, exit
    if [ ! -f "/cert/cert.pem" ] || [ ! -f "/cert/key.pem" ]; then
      _log "ERROR" "cert has not been issued"
      exit 1
    fi

    _log "INFO" "cert issued successfully"
    return 0
  fi
}

_loop() {
  while true; do
    renew_cert
    sleep_until_nextday
  done
}

_init
_loop
