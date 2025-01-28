name=${name:?"'name' variable missing!"}
control=${control:?"'control' variable missing!"}
install=${install:?"'install' variable missing!"}
postinst=${postinst?"'postinst' variable missing!"} # may be set but null
out=${out:?"'out' variable missing!"}

install -D --mode=644 --no-target-directory -- "${control}" "service-${name}/DEBIAN/control"
if [ -n "${postinst}" ]
then install -D --mode=755 --no-target-directory -- "${postinst}" "service-${name}/DEBIAN/postinst"
fi

export "profile=/nix/var/nix/profiles/per-user/root/${name}" "install_to=service-${name}"
"${install}"
dpkg-deb --root-owner-group --build "service-${name}"

install -D --mode=644 --target-directory="${out}/share" -- "service-${name}.deb"
