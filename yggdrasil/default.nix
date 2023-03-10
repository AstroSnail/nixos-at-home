{ config, lib, pkgs, ... }:

{
  services.yggdrasil.enable = true;
  services.yggdrasil.persistentKeys = true;
  services.yggdrasil.settings = {
    IfName = "yggdrasil0";
    Listen = [ "tcp://[::]:123" ];
    NodeInfo = { name = config.networking.fqdnOrHostName; };
    Peers = [ "tcp://[${config.ips.soon-ipv6}]:123" ];
  };

  systemd.services.yggdrasil.requires = [ "yggdrasil-activation.service" ];

  systemd.services.yggdrasil-activation = {
    description = "Activation script for yggdrasil";
    before = [ "yggdrasil.service" ];
    script = config.system.activationScripts.yggdrasil;
    serviceConfig.Type = "oneshot";
  };

  debianControl = ''
    Architecture: all
    Description: service-yggdrasil
    Maintainer: Erry <astrosnail@protonmail.com>
    Package: service-yggdrasil
    Version: 0.1.0-1
  '';

  installScript = lib.readFile ./install.sh;
}
