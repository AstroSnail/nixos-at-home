profile=${profile:?"'profile' variable missing!"}
install_to=${install_to:?"'install_to' variable missing!"}

service_file=/etc/systemd/system/nginx.service
service_link=/etc/systemd/system/multi-user.target.wants/nginx.service
logrotate_file=/etc/logrotate.d/nginx
tmpfiles_file=/etc/tmpfiles.d/00-nginx.conf

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
linky_relative "${install_to}${service_link}"
linky "${profile}${logrotate_file}" "${install_to}${logrotate_file}"
linky "${profile}${tmpfiles_file}" "${install_to}${tmpfiles_file}"
