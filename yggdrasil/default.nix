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

  systemd.services.yggdrasil-activation = {
    description = "Activation script for yggdrasil";
    before = [ "yggdrasil.service" ];
    requiredBy = [ "yggdrasil.service" ];
    script = config.system.activationScripts.yggdrasil;
    serviceConfig.Type = "oneshot";
  };

  debianControl = lib.readFile ./control.txt;
  installScript = lib.readFile ./install.sh;
}
