{ config, lib, ... }:

{
  boot.modprobeConfig.enable = lib.mkForce true;
  networking.nftables.enable = true;
  # Reduce logspam
  networking.firewall.logRefusedConnections = false;
  networking.firewall.rejectPackets = true;

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.firewall.interfaces.ens3.allowedTCPPorts = [ 123 ];

  environment.etc."nftables.conf".source =
    config.systemd.services.nftables.serviceConfig.ExecStart;

  installScript = builtins.readFile ./install.sh;
}
