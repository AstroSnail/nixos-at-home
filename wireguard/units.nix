{ config, lib, ... }:

{
  systemd.services = lib.mapAttrs' (
    iface: data:
    lib.nameValuePair "wireguard-${iface}" {
      requires = [ "wireguard-${iface}-key.service" ];
      wants = lib.lists.map (peer: "wireguard-${iface}-peer-${peer.name}.service") data.peers;
    }
  ) config.networking.wireguard.interfaces;
}
