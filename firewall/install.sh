# BEGIN install.sh

command=${command:?"'command' variable missing!"}
profile=${profile:?"'profile' variable missing!"}

service_file=/etc/systemd/system/nftables.service
service_link=/etc/systemd/system/multi-user.target.wants/nftables.service
service_relative=../nftables.service
modprobe_file_profile=/etc/modprobe.d/nixos.conf
modprobe_file=/etc/modprobe.d/firewall.conf

run_install () (
  ln --symbolic --no-target-directory "${profile}${service_file}" "${service_file}"
  ln --symbolic --no-target-directory "${service_relative}" "${service_link}"
  ln --symbolic --no-target-directory "${profile}${modprobe_file_profile}" "${modprobe_file}"
)

run_remove () (
  # keep trying to remove
  # e.g. to remove a partially failed install
  set +o errexit
  rmlink "${modprobe_file}"
  rmlink "${service_link}"
  rmlink "${service_file}"
)

"run_${command}" "$@"

# END install.sh
