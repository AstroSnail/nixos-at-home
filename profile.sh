# BEGIN profile.sh

command=${1:-help}
shift

name=${name:?"'name' variable missing!"}
derivation=${derivation:?"'derivation' variable missing!"}

profile_dir=/nix/var/nix/profiles/per-user/${USER}
profile=${profile_dir}/${name}

daemon_reload () {
  systemctl daemon-reload
}

trap daemon_reload EXIT

run_help () {
  echo "Examples:"
  echo "  help"
  echo "  update"
  echo "  install"
  echo "  remove"
  echo "  env --list-generations"
  echo "  env --switch-generation 42"
  echo "  env --rollback"
}

run_update () {
  nix-env --profile "${profile}" --set "${derivation}"
}

run_env () {
  nix-env --profile "${profile}" "$@"
}

# useful in remove scripts
rmlink () (
  set -o errexit
  for link
  do [ -h "${link}" ]
  done
  rm -- "$@"
)

# END profile.sh
