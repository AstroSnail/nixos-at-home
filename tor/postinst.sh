#!/bin/sh
set -eu
case $1 in
  (configure)
    if ! getent passwd tor >/dev/null
    then adduser --system --home /var/lib/tor --group tor
    fi
    if getent group nginx >/dev/null &&
       ! getent group nginx | cut -d: -f4 | tr , \\n | grep -qx tor
    then adduser tor nginx
    fi
    ;;
  (abort-upgrade|abort-remove|abort-deconfigure)
    ;;
  (*)
    echo "Unknown argument: $1" >&2
    exit 1
    ;;
esac
