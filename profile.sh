command=${1:-help}
shift

name=${name:?"'name' variable missing!"}
derivation=${derivation:?"'derivation' variable missing!"}

profile=/nix/var/nix/profiles/per-user/${USER}/${name}

run_help () {
  echo "Examples:"
  echo "  help"
  echo "  update"
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

"run_${command}" "$@"

if [ "${USER}" = root ]
then systemctl daemon-reload
else systemctl --user daemon-reload
fi
