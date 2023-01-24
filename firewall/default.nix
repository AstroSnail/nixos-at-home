{ lib, ... }:

{
  boot.modprobeConfig.enable = lib.mkForce true;
  networking.nftables.enable = true;

  networking.firewall.rejectPackets = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.firewall.interfaces.ens3.allowedTCPPorts = [ 123 ];

  installScript = builtins.readFile ./install.sh;
}
