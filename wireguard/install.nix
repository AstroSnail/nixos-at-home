{ config, lib, ... }:

{
  installScript =
    let

      interfaces = lib.attrNames config.networking.wireguard.interfaces;
      interfaces-str = lib.concatStringsSep " " interfaces;

      peers-str = peers: lib.concatStringsSep " " (lib.catAttrs "name" peers);
      iface2peers = lib.mapAttrsToList (
        iface: data: "    (${iface}) peers='${peers-str data.peers}';;"
      ) config.networking.wireguard.interfaces;
      iface2peers-str = lib.concatStringsSep "\n" iface2peers;

      text = lib.readFile ./install.sh;

    in
    lib.replaceStrings
      [ "###INTERFACES###" "###IFACE2PEERS###" ]
      [
        interfaces-str
        iface2peers-str
      ]
      text;
}
