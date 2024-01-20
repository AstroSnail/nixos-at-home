#!/bin/sh
set -eu
case $1 in
  (configure)
    if ! getent passwd pdns >/dev/null
    then adduser --system --home /var/lib/pdns --group --gecos 'PowerDNS' pdns
    fi
    ;;
  (abort-upgrade|abort-remove|abort-deconfigure)
    ;;
  (*)
    echo "Unknown argument: $1" >&2
    exit 1
    ;;
esac
