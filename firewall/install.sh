profile=${profile:?"'profile' variable missing!"}
install_to=${install_to:?"'install_to' variable missing!"}

nftables_config=/etc/nftables.conf
modprobe_file_profile=/etc/modprobe.d/nixos.conf
modprobe_file=/etc/modprobe.d/firewall.conf
nftables_service_file=/lib/systemd/system/nftables.service
nftables_service_link=/etc/systemd/system/sysinit.target.wants/nftables.service

linky () {
  link_pointer=$1
  link_name=$2
  mkdir --parents -- "${link_name%/*}"
  ln --symbolic --no-target-directory -- "${link_pointer}" "${link_name}"
}

linky "${profile}${nftables_config}" "${install_to}${nftables_config}"
linky "${profile}${modprobe_file_profile}" "${install_to}${modprobe_file}"
linky "${nftables_service_file}" "${install_to}${nftables_service_link}"
