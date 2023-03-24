profile=${profile:?"'profile' variable missing!"}
install_to=${install_to:?"'install_to' variable missing!"}

service_file=/etc/systemd/system/tor.service
service_link=/etc/systemd/system/multi-user.target.wants/tor.service

linky () {
  link_pointer=$1
  link_name=$2
  mkdir --parents "${link_name%/*}"
  ln --symbolic --no-target-directory "${link_pointer}" "${link_name}"
}

linky_relative () {
  link_name=$1
  linky "../${link_name##*/}" "${link_name}"
}

linky "${profile}${service_file}" "${install_to}${service_file}"
linky_relative "${install_to}${service_link}"

cat >"${install_to}/DEBIAN/postinst" <<-'EOF'
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
EOF
chmod +x "${install_to}/DEBIAN/postinst"
