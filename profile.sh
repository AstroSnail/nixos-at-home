# BEGIN profile.sh

command=$1
name=$2
derivation=$3

profile_dir=/nix/var/nix/profiles/per-user/${USER}
profile=${profile_dir}/${name}

rmlink () (
  set -o errexit
  for link
  do [ -h "${link}" ]
  done
  rm -- "$@"
)

daemon_reload () {
  systemctl daemon-reload
}

trap daemon_reload EXIT

run_update () {
  nix-env --profile "${profile}" --set "${derivation}"
}

# TODO: rollback

set -- "${command}" "${profile}"

# END profile.sh
