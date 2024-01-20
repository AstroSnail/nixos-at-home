#!/bin/sh
set -eu
case $1 in
  (configure)
    if ! getent passwd nginx >/dev/null
    then adduser --system --group nginx
    fi
    ;;
  (abort-upgrade|abort-remove|abort-deconfigure)
    ;;
  (*)
    echo "Unknown argument: $1" >&2
    exit 1
    ;;
esac
