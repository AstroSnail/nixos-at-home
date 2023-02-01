name=${name:?"'name' variable missing!"}
control=${control:?"'control' variable missing!"}
install=${install:?"'install' variable missing!"}
out=${out:?"'out' variable missing!"}

mkdir --parents "service-${name}/DEBIAN"
cp --no-target-directory "${control}" "service-${name}/DEBIAN/control"

export "profile=/nix/var/nix/profiles/per-user/root/${name}" "install_to=service-${name}"
"${install}"
dpkg-deb --root-owner-group --build "service-${name}"

mkdir "${out}"
mv --target-directory="${out}" "service-${name}.deb"
