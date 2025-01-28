profile=${profile:?"'profile' variable missing!"}
install_to=${install_to:?"'install_to' variable missing!"}

service_file=/etc/systemd/system/nix-gc.service
timer_file=/etc/systemd/system/nix-gc.timer
timer_link=/etc/systemd/system/timers.target.wants/nix-gc.timer

linky () {
  link_pointer=$1
  link_name=$2
  mkdir --parents -- "${link_name%/*}"
  ln --symbolic --no-target-directory -- "${link_pointer}" "${link_name}"
}

linky_relative () {
  link_name=$1
  linky "../${link_name##*/}" "${link_name}"
}

linky "${profile}${service_file}" "${install_to}${service_file}"
linky "${profile}${timer_file}" "${install_to}${timer_file}"
linky_relative "${install_to}${timer_link}"
