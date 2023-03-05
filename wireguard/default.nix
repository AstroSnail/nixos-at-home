{ config, lib, ... }:

{
  networking.wireguard.interfaces.wg_astro = {
    generatePrivateKeyFile = true;
    privateKeyFile = "/var/lib/wireguard/key";
    listenPort = 51820;
    peers = [
      { # soon
        publicKey = "Rc7Ft6ljK9pyRmrwzQmfsIEIpqsTpCu+1hlAaTfDyzc=";
        allowedIPs = [ "${config.ips.soon-wg}/128" ];
        endpoint = "[${config.ips.soon-yggd}]:51820";
      }
      { # smol
        publicKey = "Lp5hmSdapd8LPYpdLb2+8eBKq3mV6PO7gi2VIVv3d2s=";
        allowedIPs = [ "${config.ips.smol-wg}/128" ];
        #endpoint = "[${config.ips.smol-yggd}]:51820";
      }
      { # sonar
        publicKey = "spQBkQX/+mB1MmVvDnjs1IEHInDKOxPMjhgs0OyJCi8=";
        allowedIPs = [ "${config.ips.sonar-wg}/128" ];
        #endpoint = "[${config.ips.sonar-yggd}]:51820";
      }
      { # soon-prime
        publicKey = "q9Pmyalgp+Qt2NU3ewng0WW7lfFIjEEMExWqHg5CVV0=";
        allowedIPs = [ "${config.ips.soon-prime-wg}/128" ];
        endpoint = "[${config.ips.soon-prime-yggd}]:51820";
      }
    ];
    ips = [ "${config.ips.sea-wg}/64" ];
  };

  debianControl = lib.readFile ./control.txt;

  installScript = let

    interfaces = lib.attrNames config.networking.wireguard.interfaces;
    interfaces-str = lib.concatStringsSep " " interfaces;

    peers-of-iface = iface:
      builtins.map (peer:
        lib.replaceStrings [ "+" "/" "=" ] [ "\\x2b" "-" "\\x3d" ]
        peer.publicKey) config.networking.wireguard.interfaces.${iface}.peers;
    peers-of-iface-str = iface: lib.concatStringsSep " " (peers-of-iface iface);

    iface2peers = builtins.map
      (iface: "    (${iface}) peers='${peers-of-iface-str iface}';;")
      interfaces;
    iface2peers-str = lib.concatStringsSep "\n" iface2peers;

    text = lib.readFile ./install.sh;

  in lib.replaceStrings [ "###INTERFACES###" "###IFACE2PEERS###" ] [
    interfaces-str
    iface2peers-str
  ] text;
}
