{ config, lib, ... }:

{
  networking.wireguard.interfaces.wg_astro = {
    generatePrivateKeyFile = true;
    privateKeyFile = "/var/lib/wireguard/key";
    listenPort = 51820;
    peers = [
      { # soon
        publicKey = config.hosts.soon.wg-pub;
        allowedIPs = [ "${config.hosts.soon.wg-addr}/128" ];
        endpoint = "[${config.hosts.soon.yggd-addr}]:51820";
      }
      { # smol
        publicKey = config.hosts.smol.wg-pub;
        allowedIPs = [ "${config.hosts.smol.wg-addr}/128" ];
        #endpoint = "[${config.hosts.smol.yggd-addr}]:51820";
      }
      { # sonar
        publicKey = config.hosts.sonar.wg-pub;
        allowedIPs = [ "${config.hosts.sonar.wg-addr}/128" ];
        #endpoint = "[${config.hosts.sonar.yggd-addr}]:51820";
      }
      { # soon-prime
        publicKey = config.hosts.soon-prime.wg-pub;
        allowedIPs = [ "${config.hosts.soon-prime.wg-addr}/128" ];
        endpoint = "[${config.hosts.soon-prime.yggd-addr}]:51820";
      }
    ];
    ips = [ "${config.hosts.sea.wg-addr}/64" ];
  };

  debianControl = ''
    Architecture: all
    Description: service-wireguard
    Maintainer: Erry <${config.email}>
    Package: service-wireguard
    Version: 0.1.0-1
  '';

  installScript = let

    interfaces = lib.attrNames config.networking.wireguard.interfaces;
    interfaces-str = lib.concatStringsSep " " interfaces;

    peers-of-iface = { peers, ... }:
      builtins.map (peer:
        lib.replaceStrings [ "+" "/" "=" ] [ "\\x2b" "-" "\\x3d" ]
        peer.publicKey) peers;
    peers-of-iface-str = data: lib.concatStringsSep " " (peers-of-iface data);

    iface2peers = lib.mapAttrsToList
      (iface: data: "    (${iface}) peers='${peers-of-iface-str data}';;")
      config.networking.wireguard.interfaces;
    iface2peers-str = lib.concatStringsSep "\n" iface2peers;

    text = lib.readFile ./install.sh;

  in lib.replaceStrings [ "###INTERFACES###" "###IFACE2PEERS###" ] [
    interfaces-str
    iface2peers-str
  ] text;
}
