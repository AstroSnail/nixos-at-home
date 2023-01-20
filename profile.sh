command=$1
name=$2
derivation=$3

profile_dir=/nix/var/nix/profiles/per-user/${USER}
profile=${profile_dir}/${name}

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
  name_link=${name}-${generation}-link
  profile_link=${profile_dir}/${name_link}

  ln --symbolic --no-target-directory "${derivation}" "${profile_link}"
  ln --force --symbolic --no-target-directory "${name_link}" "${profile}"
}

# TODO: rollback

case ${command} in
  (install|remove) "install-${name}" "${command}" "${profile}";;
  (update) run_update;;
  (*) exit 1;;
esac

systemctl daemon-reload
