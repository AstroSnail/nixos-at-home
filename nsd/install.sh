profile=${profile:?"'profile' variable missing!"}
install_to=${install_to:?"'install_to' variable missing!"}

service_file=/etc/systemd/system/nsd.service
service_link=/etc/systemd/system/multi-user.target.wants/nsd.service
service_relative=../nsd.service
dnssec_service_file=/etc/systemd/system/nsd-dnssec.service
dnssec_service_link=/etc/systemd/system/nsd.service.wants/nsd-dnssec.service
dnssec_service_relative=../nsd-dnssec.service
dnssec_timer_file=/etc/systemd/system/nsd-dnssec.timer
dnssec_timer_link=/etc/systemd/system/nsd.service.wants/nsd-dnssec.timer
dnssec_timer_relative=../nsd-dnssec.timer
control_setup_file=/etc/systemd/system/nsd-control-setup.service
control_setup_link=/etc/systemd/system/nsd.service.wants/nsd-control-setup.service
control_setup_relative=../nsd-control-setup.service

linky () {
  link_pointer=$1
  link_name=$2
  mkdir --parents "${link_name%/*}"
  ln --symbolic --no-target-directory "${link_pointer}" "${link_name}"
}

linky "${profile}${service_file}" "${install_to}${service_file}"
linky "${service_relative}" "${install_to}${service_link}"
linky "${profile}${dnssec_service_file}" "${install_to}${dnssec_service_file}"
linky "${dnssec_service_relative}" "${install_to}${dnssec_service_link}"
linky "${profile}${dnssec_timer_file}" "${install_to}${dnssec_timer_file}"
linky "${dnssec_timer_relative}" "${install_to}${dnssec_timer_link}"
linky "${profile}${control_setup_file}" "${install_to}${control_setup_file}"
linky "${control_setup_relative}" "${install_to}${control_setup_link}"

cat >"${install_to}/DEBIAN/postinst" <<-'EOF'
	#!/bin/sh
	set -eu
	case $1 in
	  (configure)
	    if ! getent passwd nsd >/dev/null
	    then adduser --system --home /var/lib/nsd --group --gecos 'NSD service user' nsd
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
