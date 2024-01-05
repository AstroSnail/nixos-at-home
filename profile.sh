command=${1-help}
shift $(( !! $# ))

self=${self:?"'self' variable missing!"}
name=${name:?"'name' variable missing!"}

profile=/nix/var/nix/profiles/per-user/${USER}/${name}
derivation=${self}#system-${name}

run_help () {
  echo "Examples:"
  echo "  help"
  echo "  profile"
  echo "  update"
  echo "  history"
  echo "  rollback --to 123"
}

run_profile () {
  echo "${profile}"
}

run_update () {
  nix build --profile "${profile}" "${derivation}"
}

run_history () {
  nix profile history --profile "${profile}"
}

run_rollback () {
  nix profile rollback --profile "${profile}" "$@"
}

"run_${command}" "$@"

if [ "${USER}" = root ]
then systemctl daemon-reload
else systemctl --user daemon-reload
fi
