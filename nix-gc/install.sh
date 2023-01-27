# BEGIN install.sh

command=${command:?"'command' variable missing!"}
profile=${profile:?"'profile' variable missing!"}

service_file=/etc/systemd/system/nix-gc.service
timer_file=/etc/systemd/system/nix-gc.timer
timer_link=/etc/systemd/system/timers.target.wants/nix-gc.timer
timer_relative=../nix-gc.timer

run_install () (
  ln --symbolic --no-target-directory "${profile}${service_file}" "${service_file}"
  ln --symbolic --no-target-directory "${profile}${timer_file}" "${timer_file}"
  ln --symbolic --no-target-directory "${timer_relative}" "${timer_link}"
)

run_remove () (
  # keep trying to remove
  # e.g. to remove a partially failed install
  set +o errexit
  rmlink "${timer_link}"
  rmlink "${timer_file}"
  rmlink "${service_file}"
)

"run_${command}" "$@"

# END install.sh
