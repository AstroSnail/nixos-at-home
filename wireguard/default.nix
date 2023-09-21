{ config, ... }:

{
  imports = [ ./install.nix ];

  networking.wireguard.interfaces.wg_astro = {
    generatePrivateKeyFile = true;
    privateKeyFile = "/var/lib/wireguard/key";
    listenPort = 51820;
    # TODO: filter on this-host
    peers = [
      { # soon
        publicKey = config.hosts.soon.wg-pub;
        allowedIPs = [ "${config.hosts.soon.wg-addr}/128" ];
        endpoint = "[${config.hosts.soon.yggd-addr}]:51820";
      }
      { # sea
        publicKey = config.hosts.sea.wg-pub;
        allowedIPs = [ "${config.hosts.sea.wg-addr}/128" ];
        endpoint = "[${config.hosts.sea.yggd-addr}]:51820";
      }
      #{ # smol
      #  publicKey = config.hosts.smol.wg-pub;
      #  allowedIPs = [ "${config.hosts.smol.wg-addr}/128" ];
      #  endpoint = "[${config.hosts.smol.yggd-addr}]:51820";
      #}
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
