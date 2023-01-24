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
  directory. (this is necessary because the install scripts assume the profile
  directory belongs to the current user, and linking to /etc requires root, and
  idk how to do this better)
- `sudo nix run .#yggdrasil install` to link the yggdrasil service in the
  profile to the system.
- `sudo nix run .#yggdrasil remove` to unlink.
- `sudo nix run .#yggdrasil env <whatever>` to run nix-env on the profile.
- `sudo nix run .#yggdrasil help` to see a summary of things you can do.
- You'll need to manually start and stop the service,
  e.g. `sudo systemctl start yggdrasil.service`
- BEWARE that the install/remove script may depend on the module configuration,
  and running remove on an altered configuration might not cleanly remove the
  service. NixOS knows how to stop-alter-start this properly, but i don't so
  you'll have to keep this in mind manually.
- E.g. `git stash push`, `sudo nix run .#wireguard remove`, `git stash pop`,
  `sudo nix run .#wireguard update`, `sudo nix run .#wireguard install`
- Systemd will complain but probably won't do anything else when you remove
  the service files of a running service. But unless it's critical networking
  stuff you probably want to stop them first anyway.
- Remember to restart the service after updates.

Writing a service module yourself:
- Good luck.
- So the first step is to make a directory, say `foobar`.
- Add a `foobar/default.nix` file containing the configuration module and an
  `installScript` attribute containing the install script.
- Add it to the services in flake.nix (line 6 at this time).
- :tada:

Ok but wtf is the installScript supposed to be:
- Yeah ok this is the hard and tedious part.
- Before that, a tip: run `nix flake show` to get an overview of the flake
  without having to understand the awful nix code i wrote.
- You can do `nix build .#system-foobar` to inspect what the NixOS system
  contains so you can know where to link the services.
- But you really really really should read what the NixOS system service module
  is actually doing (e.g.
  <nixpkgs>/nixos/modules/services/networking/yggdrasil.nix contains an
  `activationScripts` script, which i had to replicate into a new sub-service).
- So, the script format is a bit messy, technically it's cat'd to other scripts
  to make the app that you get with `nix run`.
- The installScript is expected to install and remove links to the profile, but
  also to run the commands for the main profile script as well. i should
  probably do it differently but it works for now.
- Run `nix build .#app-foobar` to see the final result if you're curious.

Thanks:
- Me :P
- Nerath/lun* for help figuring out the profile-setting
