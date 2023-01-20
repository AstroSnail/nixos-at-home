command=$1
profile=$2

service_file=/etc/systemd/system/yggdrasil.service
service_link=/etc/systemd/system/multi-user.target.wants/yggdrasil.service
service_relative=../yggdrasil.service
service_requires_dir=/etc/systemd/system/yggdrasil.service.requires
activation_file=/etc/systemd/system/yggdrasil-activation.service
activation_link=/etc/systemd/system/yggdrasil.service.requires/yggdrasil-activation.service
activation_relative=../yggdrasil-activation.service

rmlink () (
  set -eu
  [ -h "$1" ]
  rm -- "$1"
)

run_install () {
  set -e
  ln --symbolic --no-target-directory "${profile}${service_file}" "${service_file}"
  ln --symbolic --no-target-directory "${service_relative}" "${service_link}"
  mkdir --parents "${service_requires_dir}"
  ln --symbolic --no-target-directory "${profile}${activation_file}" "${activation_file}"
  ln --symbolic --no-target-directory "${activation_relative}" "${activation_link}"
}

run_remove () {
  set +e
  rmlink "${activation_link}"
  rmlink "${activation_file}"
  rmdir "${service_requires_dir}"
  rmlink "${service_link}"
  rmlink "${service_file}"
}

"run_${command}"
