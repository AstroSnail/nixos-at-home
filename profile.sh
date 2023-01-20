command=$1
name=$2
derivation=$3

profile=/nix/var/nix/profiles/per-user/${USER}/${name}

run_update () {
  # All this just to get the next profile generation
  max_gen=0
  for link in "${profile}"-*-link
  do
    # if not, we got a literal *, not a glob match
    if [ -e "${link}" ] || [ -h "${link}" ]
    then
      linkSuffix=${link#"${profile}-"}
      gen=${linkSuffix%"-link"}
      if [ "${gen}" -gt "${max_gen}" ]
      then max_gen=${gen}
      fi
    fi
  done

  generation=$((max_gen + 1))
  profile_link=${profile}-${generation}-link

  ln --symbolic --no-target-directory "${derivation}" "${profile_link}"
  ln --force --relative --symbolic --no-target-directory "${profile_link}" "${profile}"
}

# TODO: rollback

case ${command} in
  (install|remove) "install-${name}" "${command}" "${profile}";;
  (update) run_update;;
  (*) exit 1;;
esac

systemctl daemon-reload
