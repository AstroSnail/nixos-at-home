# BEGIN install.sh

command=${command:?"'command' variable missing!"}
profile=${profile:?"'profile' variable missing!"}

nftables_config=/etc/nftables.conf
nftables_config_backup=/etc/nftables.conf.bak
modprobe_file_profile=/etc/modprobe.d/nixos.conf
modprobe_file=/etc/modprobe.d/firewall.conf

run_install () (
  # save possibly pre-existing nftables config
  if [ -e "${nftables_config}" ]
  then mv "${nftables_config}" "${nftables_config_backup}"
  fi
  ln --symbolic --no-target-directory "${profile}${nftables_config}" "${nftables_config}"
  ln --symbolic --no-target-directory "${profile}${modprobe_file_profile}" "${modprobe_file}"
)

run_remove () (
  # keep trying to remove
  # e.g. to remove a partially failed install
  set +o errexit
  rmlink "${modprobe_file}"
  rmlink "${nftables_config}"
  # restore possibly pre-existing nftables config
  if [ -e "${nftables_config_backup}" ]
  then mv "${nftables_config_backup}" "${nftables_config}"
  fi
)

"run_${command}" "$@"

# END install.sh
