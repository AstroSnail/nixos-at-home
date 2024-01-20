#!/bin/sh
set -eu
case $1 in
  (configure)
    if ! getent passwd acme >/dev/null
    then adduser --system --home /var/lib/acme --group acme
    fi
    ;;
  (abort-upgrade|abort-remove|abort-deconfigure)
    ;;
  (*)
    echo "Unknown argument: $1" >&2
    exit 1
    ;;
esac
