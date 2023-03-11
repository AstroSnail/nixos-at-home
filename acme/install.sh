# TODO: edit cert services to require account, instead of inverse requiredBy

profile=${profile:?"'profile' variable missing!"}
install_to=${install_to:?"'install_to' variable missing!"}

fixperms_service_file=/etc/systemd/system/acme-fixperms.service
selfca_service_file=/etc/systemd/system/acme-selfsigned-ca.service

set_cert_vars () {
  service_file=/etc/systemd/system/acme-${cert}.service
  service_link=/etc/systemd/system/multi-user.target.wants/acme-${cert}.service
  selfcert_service_file=/etc/systemd/system/acme-selfsigned-${cert}.service
  timer_file=/etc/systemd/system/acme-${cert}.timer
  timer_link=/etc/systemd/system/timers.target.wants/acme-${cert}.timer
  target_file=/etc/systemd/system/acme-finished-${cert}.target
  target_link=/etc/systemd/system/default.target.wants/acme-finished-${cert}.target
}

set_account_vars () {
  account_target_file=/etc/systemd/system/acme-account-${account}.target
  account_to_required_by
}

set_req_by_cert_vars () {
  account_target_link=/etc/systemd/system/acme-${req_by_cert}.service.requires/acme-account-${account}.target
}

account_to_required_by () {
  case ${account} in
###REQUIREDBY###
    (*) required_by=;;
  esac
}

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

linky "${profile}${fixperms_service_file}" "${install_to}${fixperms_service_file}"
linky "${profile}${selfca_service_file}" "${install_to}${selfca_service_file}"

set -- ###CERTS###
for cert
do
  set_cert_vars
  linky "${profile}${service_file}" "${install_to}${service_file}"
  linky_relative "${install_to}${service_link}"
  linky "${profile}${selfcert_service_file}" "${install_to}${selfcert_service_file}"
  linky "${profile}${timer_file}" "${install_to}${timer_file}"
  linky_relative "${install_to}${timer_link}"
  linky "${profile}${target_file}" "${install_to}${target_file}"
  linky_relative "${install_to}${target_link}"
done

set -- ###ACCOUNTS###
for account
do
  set_account_vars
  linky "${profile}${account_target_file}" "${install_to}${account_target_file}"
  for req_by_cert in ${required_by}
  do
    set_req_by_cert_vars
    linky_relative "${install_to}${account_target_link}"
  done
done

cat >"${install_to}/DEBIAN/postinst" <<-'EOF'
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
EOF
chmod +x "${install_to}/DEBIAN/postinst"
