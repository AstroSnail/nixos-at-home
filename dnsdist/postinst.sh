#!/bin/sh
set -eu
case $1 in
  (configure)
    if ! getent passwd dnsdist >/dev/null
    then adduser --system --home /var/lib/dnsdist --group --gecos 'dnsdist daemons user' dnsdist
    fi
    ;;
  (abort-upgrade|abort-remove|abort-deconfigure)
    ;;
  (*)
    echo "Unknown argument: $1" >&2
    exit 1
    ;;
esac
