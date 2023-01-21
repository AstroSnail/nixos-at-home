# BEGIN install.sh

command=$1
profile=$2

set_iface_vars () {
  service_file=/etc/systemd/system/wireguard-${interface}.service
  service_requires_dir=/etc/systemd/system/wireguard-${interface}.service.requires
  service_wants_dir=/etc/systemd/system/wireguard-${interface}.service.wants
  target_file=/etc/systemd/system/wireguard-${interface}.target
  target_link=/etc/systemd/system/multi-user.target.wants/wireguard-${interface}.target
  target_relative=../wireguard-${interface}.target
  key_file=/etc/systemd/system/wireguard-${interface}-key.service
  key_link=/etc/systemd/system/wireguard-${interface}.service.requires/wireguard-${interface}-key.service
  key_relative=../wireguard-${interface}-key.service
  peer_files_profile="${profile}/etc/systemd/system/wireguard-${interface}-peer-*.service"
}

set_peer_vars () {
  peer_file_name=${peer_file_profile##*/}
  peer_file=/etc/systemd/system/${peer_file_name}
  peer_link=/etc/systemd/system/wireguard-${interface}.service.wants/${peer_file_name}
  peer_relative=../${peer_file_name}
}

run_install () {
  # keep trying to install
  # e.g. to install new interfaces
  set +o errexit
  set -- ###INTERFACES###
  for interface
  do
    set_iface_vars
    ln --symbolic --no-target-directory "${profile}${service_file}" "${service_file}"
    ln --symbolic --no-target-directory "${profile}${target_file}" "${target_file}"
    ln --symbolic --no-target-directory "${target_relative}" "${target_link}"
    ln --symbolic --no-target-directory "${profile}${key_file}" "${key_file}"
    mkdir --parents "${service_requires_dir}"
    ln --symbolic --no-target-directory "${key_relative}" "${key_link}"

    mkdir --parents "${service_wants_dir}"
    for peer_file_profile in ${peer_files_profile}
    do
      set_peer_vars
      ln --symbolic --no-target-directory "${peer_file_profile}" "${peer_file}"
      ln --symbolic --no-target-directory "${peer_relative}" "${peer_link}"
    done
  done
  echo "WARNING: if you ever edit the config, mind what's installed" >&2
}

run_remove () {
  # keep trying to remove
  # e.g. to remove a partially failed install
  set +o errexit
  set -- ###INTERFACES###
  for interface
  do
    set_iface_vars
    for peer_file_profile in ${peer_files_profile}
    do
      set_peer_vars
      rmlink "${peer_link}"
      rmlink "${peer_file}"
    done
    rmdir "${service_wants_dir}"
    rmlink "${key_link}"
    rmdir "${service_requires_dir}"
    rmlink "${key_file}"
    rmlink "${target_link}"
    rmlink "${target_file}"
    rmlink "${service_file}"
  done
}

"run_${command}"

# END install.sh
