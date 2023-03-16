{ config, lib, ... }:

{
  services.yggdrasil.enable = true;
  services.yggdrasil.persistentKeys = true;
  services.yggdrasil.settings = {
    IfName = "yggdrasil0";
    Listen = [ "tcp://[::]:123" ];
    AllowedPublicKeys = [
      config.hosts.soon.yggd-pub
      config.hosts.sea.yggd-pub
      config.hosts.sonar.yggd-pub
      config.hosts.soon-prime.yggd-pub
    ];
    Peers = [ "tcp://[${config.hosts.soon.ipv6}]:123" ];
    NodeInfo = { name = config.networking.fqdnOrHostName; };
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
    Maintainer: Erry <${config.email}>
    Package: service-yggdrasil
    Version: 0.1.0-1
  '';

  installScript = lib.readFile ./install.sh;
}
