profile=${profile:?"'profile' variable missing!"}
install_to=${install_to:?"'install_to' variable missing!"}

fixperms_service_file=/etc/systemd/system/acme-fixperms.service
lockfiles_service_file=/etc/systemd/system/acme-lockfiles.service
selfca_service_file=/etc/systemd/system/acme-selfsigned-ca.service
tmpfiles_file=/etc/tmpfiles.d/00-acme.conf

set_cert_vars () {
  service_file=/etc/systemd/system/acme-${cert}.service
  selfcert_service_file=/etc/systemd/system/acme-selfsigned-${cert}.service
  ocsp_service_file=/etc/systemd/system/acme-ocsp-${cert}.service
  finished_target_file=/etc/systemd/system/acme-finished-${cert}.target
  target_file=/etc/systemd/system/acme-${cert}.target
  timer_file=/etc/systemd/system/acme-${cert}.timer
  timer_link=/etc/systemd/system/timers.target.wants/acme-${cert}.timer
}

set_account_vars () {
  account_target_file=/etc/systemd/system/acme-account-${account}.target
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
linky "${profile}${lockfiles_service_file}" "${install_to}${lockfiles_service_file}"
linky "${profile}${selfca_service_file}" "${install_to}${selfca_service_file}"
linky "${profile}${tmpfiles_file}" "${install_to}${tmpfiles_file}"

set -- ###CERTS###
for cert
do
  set_cert_vars
  linky "${profile}${service_file}" "${install_to}${service_file}"
  linky "${profile}${selfcert_service_file}" "${install_to}${selfcert_service_file}"
  linky "${profile}${ocsp_service_file}" "${install_to}${ocsp_service_file}"
  linky "${profile}${finished_target_file}" "${install_to}${finished_target_file}"
  linky "${profile}${target_file}" "${install_to}${target_file}"
  linky "${profile}${timer_file}" "${install_to}${timer_file}"
  linky_relative "${install_to}${timer_link}"
done

set -- ###ACCOUNTS###
for account
do
  set_account_vars
  linky "${profile}${account_target_file}" "${install_to}${account_target_file}"
done
