profile=${profile:?"'profile' variable missing!"}
install_to=${install_to:?"'install_to' variable missing!"}

service_file=/etc/systemd/system/yggdrasil.service
service_link=/etc/systemd/system/multi-user.target.wants/yggdrasil.service
service_relative=../yggdrasil.service
activation_file=/etc/systemd/system/yggdrasil-activation.service
activation_link=/etc/systemd/system/yggdrasil.service.requires/yggdrasil-activation.service
activation_relative=../yggdrasil-activation.service

linky () {
  link_pointer=$1
  link_name=$2
  mkdir --parents "${link_name%/*}"
  ln --symbolic --no-target-directory "${link_pointer}" "${link_name}"
}

linky "${profile}${service_file}" "${install_to}${service_file}"
linky "${service_relative}" "${install_to}${service_link}"
linky "${profile}${activation_file}" "${install_to}${activation_file}"
linky "${activation_relative}" "${install_to}${activation_link}"
