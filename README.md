# Get NixOS services on a not-NixOS system
- You still need nix though.
- Also requires that the system runs systemd because NixOS systems are based on
  systemd.
- Also assumes the system uses `dpkg` (Debian, Ubuntu, ...) but you can
  probably work around that.

## Overview:
- You know how a NixOS configuration is a module where you enable a bunch of
  services and whatever.
- `nixos-rebuild` combines this configuration module with the rest of the NixOS
  modules to create a system.
- This system is a derivation, put into a profile somewhere and linked around
  the filesystem.
- Remember that profiles are in `/nix/var/nix/profiles`.
- What if you could control this last linking step? Carefully install only the
  services you want, without installing a whole NixOS system.
- Basically this is what this is.
- Each "service" directory contains a kind of NixOS configuration, which
  specifies the services to enable, and build instructions for a package.
- The NixOS configuration is put into a profile.
- The package contains the symlinks to the profile, so that the system's
  package manager handles the necessary system state.
- After installing a package, updates of the services are done on the profile,
  so reinstalling the package isn't necessary (unless there are new files).

## Usage examples:
- `nix run .#yggdrasil update` to add/update the yggdrasil service in the
  current user's profile directory.
- `sudo nix run .#yggdrasil update` to do this on the root user's profile
  directory.
  - This is necessary because the packages (see next point) link to the root
    user's profile directory, but if you're not using a package for a
    particular module then you can link it to your own user's profile and
    figure it out yourself.
- `sudo nix run .#yggdrasil env <whatever>` to run `nix-env` on the profile.
- `sudo nix run .#yggdrasil help` to see a summary of things you can do.
- `nix build .#package-yggdrasil` to get a Debian/Ubuntu package containing the
  symlinks to the service's profile.
- You'll need to manually start and stop the service,
  e.g. `sudo systemctl start yggdrasil.service`.
- The service is automatically enabled though (mainly to reduce the amount of
  unaccounted-for system state), so you can also just reboot.
- Systemd will complain but probably won't do anything else when you remove
  the service files of a running service. But unless it's critical networking
  stuff you probably want to stop them first anyway.
- Remember to restart the service after updates.

## Writing a service module yourself:
- Good luck.
- Make a directory, say `foobar`.
- Add a `foobar/default.nix` file containing the configuration module, a
  `debianControl` attribute containing text for a Debian package control file,
  and an `installScript` attribute containing the package install script to
  create the package.
- Add `"foobar"` to the services in `flake.nix` (under line 6 at this time).
- :tada:

## Thanks:
- [Me](/AstroSnail). :P
- [Nerath/lun\*](/LunNova) for help figuring out the profile-setting.

## Useful other commands while installing:
- `sudo dpkg-divert --package service-firewall --divert /etc/nftables.conf.divert --rename --add /etc/nftables.conf`
  - The `firewall` service here interferes with `nftables` in Ubuntu, but the
    existing nftables service is valuable so, instead of specifying a conflict
    in the package, the conflict is diverted.
- `sudo apt autoremove`
  - The `ubuntu-advantage-tools-stub` """service""" (it's unrelated to NixOS,
    it only meaningfully makes a package for Ubuntu to remove ads) replaces
    `ubuntu-advantage-tools` in Ubuntu, and some dependencies are left dangling
    as a result.
