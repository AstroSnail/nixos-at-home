{ config, lib, ... }:

{
  nix.gc.automatic = true;
  nix.gc.dates = "03:15";
  nix.gc.randomizedDelaySec = "45min";
  nix.gc.options = "--delete-old";

  debianControl = ''
    Architecture: all
    Description: service-nix-gc
    Maintainer: Erry <${config.email}>
    Package: service-nix-gc
    Version: 0.1.0-1
  '';

  installScript = lib.readFile ./install.sh;
}
