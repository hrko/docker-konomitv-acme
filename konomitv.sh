#!/bin/sh

cd /code/server || exit

# if cert does not installed, exit gracefully.
# note: this script is automatically restarted after cert is installed.
if [ ! -f "/cert/cert.pem" ] || [ ! -f "/cert/key.pem" ]; then
  echo "cert has not been issued, stopping konomitv"
  exit 0
fi

/code/server/thirdparty/Python/bin/python -m pipenv run aerich upgrade && \
exec /code/server/.venv/bin/python KonomiTV.py
