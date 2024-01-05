{ config, lib, ... }:

{
  imports = [ ./install.nix ];

  networking.wireguard.interfaces.wg_astro = {
    generatePrivateKeyFile = true;
    privateKeyFile = "/var/lib/wireguard/key";
    listenPort = 51820;
    peers = lib.concatMap (host:
      lib.optional (host != config.this-host && host.wg-pub != null) {
        publicKey = host.wg-pub;
        allowedIPs = [ "${host.wg-addr}/128" ];
        endpoint = "[${host.yggd-addr}]:51820";
      }) (lib.attrValues config.hosts);
    ips = [ "${config.this-host.wg-addr}/64" ];
  };

  debianControl = ''
    Architecture: all
    Description: service-wireguard
    Maintainer: Erry <${config.email}>
    Package: service-wireguard
    Version: 0.1.0-1
  '';
}
