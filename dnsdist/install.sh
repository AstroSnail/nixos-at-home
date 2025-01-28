profile=${profile:?"'profile' variable missing!"}
install_to=${install_to:?"'install_to' variable missing!"}

service_file=/etc/systemd/system/dnsdist.service
service_override=/etc/systemd/system/dnsdist.service.d/overrides.conf
service_link=/etc/systemd/system/multi-user.target.wants/dnsdist.service

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
linky "${profile}${service_override}" "${install_to}${service_override}"
linky_relative "${install_to}${service_link}"
