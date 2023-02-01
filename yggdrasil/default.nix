{ config, pkgs, ... }:

{
  services.yggdrasil.enable = true;
  services.yggdrasil.persistentKeys = true;
  services.yggdrasil.settings = {
    IfName = "yggdrasil0";
    Listen = [ "tcp://[::]:123" ];
    NodeInfo = { name = config.networking.fqdnOrHostName; };
    Peers = [ "tcp://[2001:818:df73:f400::abba:cad:abba]:123" ];
  };

  systemd.services.yggdrasil-activation = {
    description = "Activation script for yggdrasil";
    before = [ "yggdrasil.service" ];
    requiredBy = [ "yggdrasil.service" ];
    script = config.system.activationScripts.yggdrasil;
    serviceConfig.Type = "oneshot";
  };

  debianControl = builtins.readFile ./control.txt;
  installScript = builtins.readFile ./install.sh;
}
