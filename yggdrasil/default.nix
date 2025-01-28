{ config, lib, ... }:

{
  services.yggdrasil.enable = true;
  services.yggdrasil.persistentKeys = true;
  services.yggdrasil.settings = {
    IfName = "yggdrasil0";
    Listen = [
      "tcp://${config.this-host.ipv4}:123"
      "tcp://[${config.this-host.ipv6}]:123"
    ];
    AllowedPublicKeys = lib.pipe config.hosts [
      lib.attrValues
      (lib.catAttrs "yggd-pub")
      (lib.remove null)
    ];
    Peers =
      lib.concatMap
        (
          host:
          lib.optionals (host != config.this-host) [
            "tcp://${host.ipv4}:123"
            "tcp://[${host.ipv6}]:123"
          ]
        )
        [
          config.hosts.soon
          config.hosts.sea
        ];
    NodeInfo = {
      name = config.networking.fqdnOrHostName;
    };
    MulticastInterfaces = [ ];
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
