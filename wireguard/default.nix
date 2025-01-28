{ config, lib, ... }:

{
  imports = [
    ./units.nix
    ./install.nix
  ];

  networking.wireguard.interfaces.wg_astro = {
    generatePrivateKeyFile = true;
    privateKeyFile = "/var/lib/wireguard/key";
    listenPort = 51820;
    peers = lib.concatLists (
      lib.mapAttrsToList (
        name: host:
        lib.optional (host != config.this-host && host.wg-pub != null) {
          inherit name;
          publicKey = host.wg-pub;
          allowedIPs = [ "${host.wg-addr}/128" ];
          endpoint = "[${host.yggd-addr}]:51820";
        }
      ) config.hosts
    );
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
