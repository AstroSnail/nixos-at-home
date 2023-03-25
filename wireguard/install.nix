{ config, lib, ... }:

{
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
