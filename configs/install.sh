# BEGIN install.sh

command=${command:?"'command' variable missing!"}
profile=${profile:?"'profile' variable missing!"}

apt_periodic_file=/etc/apt/apt.conf.d/11periodic-edit
apt_auto_upgrades_file=/etc/apt/apt.conf.d/21auto-upgrades-edit
sshd_config_file=/etc/ssh/sshd_config.d/my.conf
journald_conf_dir=/etc/systemd/journald.conf.d
journald_conf_file=/etc/systemd/journald.conf.d/system-max-use.conf

run_install () (
  ln --symbolic --no-target-directory "${profile}${apt_periodic_file}" "${apt_periodic_file}"
  ln --symbolic --no-target-directory "${profile}${apt_auto_upgrades_file}" "${apt_auto_upgrades_file}"
  ln --symbolic --no-target-directory "${profile}${sshd_config_file}" "${sshd_config_file}"
  mkdir --parents "${journald_conf_dir}"
  ln --symbolic --no-target-directory "${profile}${journald_conf_file}" "${journald_conf_file}"
)

run_remove () (
  # keep trying to remove
  # e.g. to remove a partially failed install
  set +o errexit
  rmlink "${journald_conf_file}"
  rmdir "${journald_conf_dir}"
  rmlink "${sshd_config_file}"
  rmlink "${apt_auto_upgrades_file}"
  rmlink "${apt_periodic_file}"
)

"run_${command}" "$@"

# END install.sh
