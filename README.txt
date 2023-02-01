Get NixOS services on a not-NixOS system
(you still need nix though)
(also requires that the system runs systemd)

Overview:
- You know how NixOS configuration is a module where you enable a bunch of
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
  specifies the services to enable, and an install script that installs this
  service on the existing system.

Usage examples:
- `nix run .#yggdrasil update` to add/update the yggdrasil service in the
  current user's profile directory.
- `sudo nix run .#yggdrasil update` to do this on the root user's profile
  directory. (this is necessary because packages [see later] link to the root
  user's profile directory, but if you're not using the packages then do
  whatever :p)
- `nix build .#package-yggdrasil` to get a Ubuntu package containing the
  symlinks, ready to install with the package manager.
- `sudo nix run .#yggdrasil env <whatever>` to run nix-env on the profile.
- `sudo nix run .#yggdrasil help` to see a summary of things you can do.
- You'll need to manually start and stop the service,
  e.g. `sudo systemctl start yggdrasil.service`
- Systemd will complain but probably won't do anything else when you remove
  the service files of a running service. But unless it's critical networking
  stuff you probably want to stop them first anyway.
- Remember to restart the service after updates.

Writing a service module yourself:
- Good luck.
- So the first step is to make a directory, say `foobar`.
- Add a `foobar/default.nix` file containing the configuration module and an
  `installScript` attribute containing the install script.
- The install script is what creates the package.
- Add it to the services in flake.nix (line 6 at this time).
- :tada:

Thanks:
- Me :P
- Nerath/lun* for help figuring out the profile-setting
