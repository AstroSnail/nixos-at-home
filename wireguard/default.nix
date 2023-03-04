{ config, lib, ... }:

{
  networking.wireguard.interfaces.wg_astro = {
    generatePrivateKeyFile = true;
    privateKeyFile = "/var/lib/wireguard/key";
    listenPort = 51820;
    peers = [
      { # soon
        publicKey = "Rc7Ft6ljK9pyRmrwzQmfsIEIpqsTpCu+1hlAaTfDyzc=";
        allowedIPs = [ "fd57:337f:9040:1:2:3:4:5/128" ];
        endpoint = "[200:677f:abc:380b:6c78:73b5:c72e:c1f3]:51820";
      }
      { # smol
        publicKey = "Lp5hmSdapd8LPYpdLb2+8eBKq3mV6PO7gi2VIVv3d2s=";
        allowedIPs = [ "fd57:337f:9040:1:1:1:1:2/128" ];
        #endpoint = "[]:51820";
      }
      { # sonar
        publicKey = "spQBkQX/+mB1MmVvDnjs1IEHInDKOxPMjhgs0OyJCi8=";
        allowedIPs = [ "fd57:337f:9040:1:9ca7:9ca7:9ca7:9ca7/128" ];
        #endpoint = "[202:2d0d:edc4:38af:ccb9:efb6:59de:421d]:51820";
      }
      { # soon-prime
        publicKey = "q9Pmyalgp+Qt2NU3ewng0WW7lfFIjEEMExWqHg5CVV0=";
        allowedIPs = [ "fd57:337f:9040:1:5:4:3:2/128" ];
        endpoint = "[200:2ab6:23c:e13c:5902:4bbc:4afe:509c]:51820";
      }
    ];
    ips = [ "fd57:337f:9040:1::5ea/64" ];
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
