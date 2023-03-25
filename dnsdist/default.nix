{ config, lib, ... }:

{
  imports = [ ./config.nix ];

  services.dnsdist.enable = true;

  systemd.services.dnsdist = {
    wants = [ "acme-finished-astrosnail.target" ];
    after = [ "acme-finished-astrosnail.target" ];
    serviceConfig.SupplementaryGroups = "acme";
  };

  debianControl = ''
    Architecture: all
    Description: service-dnsdist
    Maintainer: Erry <${config.email}>
    Package: service-dnsdist
    Version: 0.1.0-1
  '';

  installScript = lib.readFile ./install.sh;
}
