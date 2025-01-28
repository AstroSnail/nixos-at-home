profile=${profile:?"'profile' variable missing!"}
install_to=${install_to:?"'install_to' variable missing!"}

apt_periodic_file=/etc/apt/apt.conf.d/11periodic-edit
apt_auto_upgrades_file=/etc/apt/apt.conf.d/21auto-upgrades-edit
default_motd_news_file=/etc/default/motd-news
#netplan_ipv6_file=/etc/netplan/51-ipv6.yaml
sshd_config_file=/etc/ssh/sshd_config.d/00-my.conf
journald_conf_file=/etc/systemd/journald.conf.d/00-system-max-use.conf
update_notifier_hide_esm=/var/lib/update-notifier/hide-esm-in-motd

linky () {
  link_pointer=$1
  link_name=$2
  mkdir --parents -- "${link_name%/*}"
  ln --symbolic --no-target-directory -- "${link_pointer}" "${link_name}"
}

touchy () {
  file_name=$1
  mkdir --parents -- "${file_name%/*}"
  touch -- "${file_name}"
}

linky "${profile}${apt_periodic_file}" "${install_to}${apt_periodic_file}"
linky "${profile}${apt_auto_upgrades_file}" "${install_to}${apt_auto_upgrades_file}"
linky "${profile}${default_motd_news_file}" "${install_to}${default_motd_news_file}"
#linky "${profile}${netplan_ipv6_file}" "${install_to}${netplan_ipv6_file}"
linky "${profile}${sshd_config_file}" "${install_to}${sshd_config_file}"
linky "${profile}${journald_conf_file}" "${install_to}${journald_conf_file}"
touchy "${install_to}${update_notifier_hide_esm}"
