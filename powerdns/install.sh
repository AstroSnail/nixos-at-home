profile=${profile:?"'profile' variable missing!"}
install_to=${install_to:?"'install_to' variable missing!"}

service_file=/etc/systemd/system/pdns.service
service_override=/etc/systemd/system/pdns.service.d/overrides.conf
service_link=/etc/systemd/system/multi-user.target.wants/pdns.service
database_setup_file=/etc/systemd/system/pdns-sqlite3-setup.service
update_zone_file=/etc/systemd/system/pdns-update-zone.service
rollover_zsk_phase1_service_file=/etc/systemd/system/pdns-rollover-zsk-phase1.service
rollover_zsk_phase1_timer_file=/etc/systemd/system/pdns-rollover-zsk-phase1.timer
rollover_zsk_phase2_service_file=/etc/systemd/system/pdns-rollover-zsk-phase2.service
rollover_zsk_phase2_timer_file=/etc/systemd/system/pdns-rollover-zsk-phase2.timer
rollover_zsk_phase3_service_file=/etc/systemd/system/pdns-rollover-zsk-phase3.service
rollover_zsk_phase3_timer_file=/etc/systemd/system/pdns-rollover-zsk-phase3.timer
rollover_ksk_phase1_service_file=/etc/systemd/system/pdns-rollover-ksk-phase1.service
rollover_ksk_phase1_timer_file=/etc/systemd/system/pdns-rollover-ksk-phase1.timer
rollover_ksk_phase2_service_file=/etc/systemd/system/pdns-rollover-ksk-phase2.service
rollover_ksk_phase2_timer_file=/etc/systemd/system/pdns-rollover-ksk-phase2.timer
rollover_target_file=/etc/systemd/system/pdns-rollover.target
rollover_target_link=/etc/systemd/system/timers.target.wants/pdns-rollover.target

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
linky "${profile}${rollover_zsk_phase1_service_file}" "${install_to}${rollover_zsk_phase1_service_file}"
linky "${profile}${rollover_zsk_phase1_timer_file}" "${install_to}${rollover_zsk_phase1_timer_file}"
linky "${profile}${rollover_zsk_phase2_service_file}" "${install_to}${rollover_zsk_phase2_service_file}"
linky "${profile}${rollover_zsk_phase2_timer_file}" "${install_to}${rollover_zsk_phase2_timer_file}"
linky "${profile}${rollover_zsk_phase3_service_file}" "${install_to}${rollover_zsk_phase3_service_file}"
linky "${profile}${rollover_zsk_phase3_timer_file}" "${install_to}${rollover_zsk_phase3_timer_file}"
linky "${profile}${rollover_ksk_phase1_service_file}" "${install_to}${rollover_ksk_phase1_service_file}"
linky "${profile}${rollover_ksk_phase1_timer_file}" "${install_to}${rollover_ksk_phase1_timer_file}"
linky "${profile}${rollover_ksk_phase2_service_file}" "${install_to}${rollover_ksk_phase2_service_file}"
linky "${profile}${rollover_ksk_phase2_timer_file}" "${install_to}${rollover_ksk_phase2_timer_file}"
linky "${profile}${rollover_target_file}" "${install_to}${rollover_target_file}"
linky_relative "${install_to}${rollover_target_link}"

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
