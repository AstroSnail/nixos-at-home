# TODO: edit interface services to require key and want peers, instead of
#       inverse requiredBy and wantedBy

profile=${profile:?"'profile' variable missing!"}
install_to=${install_to:?"'install_to' variable missing!"}

set_iface_vars () {
  service_file=/etc/systemd/system/wireguard-${interface}.service
  target_file=/etc/systemd/system/wireguard-${interface}.target
  target_link=/etc/systemd/system/multi-user.target.wants/wireguard-${interface}.target
  key_file=/etc/systemd/system/wireguard-${interface}-key.service
  key_link=/etc/systemd/system/wireguard-${interface}.service.requires/wireguard-${interface}-key.service
  iface_to_peers
}

set_peer_vars () {
  peer_file_name=wireguard-${interface}-peer-${peer}.service
  peer_file=/etc/systemd/system/${peer_file_name}
  peer_link=/etc/systemd/system/wireguard-${interface}.service.wants/${peer_file_name}
}

iface_to_peers () {
  case ${interface} in
###IFACE2PEERS###
    (*) peers=;;
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

set -- ###INTERFACES###
for interface
do
  set_iface_vars
  linky "${profile}${service_file}" "${install_to}${service_file}"
  linky "${profile}${target_file}" "${install_to}${target_file}"
  linky_relative "${install_to}${target_link}"
  linky "${profile}${key_file}" "${install_to}${key_file}"
  linky_relative "${install_to}${key_link}"
  for peer in ${peers}
  do
    set_peer_vars
    linky "${profile}${peer_file}" "${install_to}${peer_file}"
    linky_relative "${install_to}${peer_link}"
  done
done
