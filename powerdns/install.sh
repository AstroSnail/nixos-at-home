profile=${profile:?"'profile' variable missing!"}
install_to=${install_to:?"'install_to' variable missing!"}

service_file=/etc/systemd/system/pdns.service
service_override=/etc/systemd/system/pdns.service.d/overrides.conf
service_link=/etc/systemd/system/multi-user.target.wants/pdns.service
database_setup_file=/etc/systemd/system/pdns-sqlite3-setup.service
update_zone_file=/etc/systemd/system/pdns-update-zone.service

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
linky "${profile}${service_override}" "${install_to}${service_override}"
linky_relative "${install_to}${service_link}"
linky "${profile}${database_setup_file}" "${install_to}${database_setup_file}"
linky "${profile}${update_zone_file}" "${install_to}${update_zone_file}"

cat >"${install_to}/DEBIAN/postinst" <<-'EOF'
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
EOF
chmod +x "${install_to}/DEBIAN/postinst"
