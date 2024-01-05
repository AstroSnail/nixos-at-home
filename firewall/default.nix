{ config, lib, ... }:

{
  boot.modprobeConfig.enable = lib.mkForce true;
  networking.nftables.enable = true;
  networking.nftables.flushRuleset = true;
  # Reduce logspam
  networking.firewall.logRefusedConnections = false;
  networking.firewall.rejectPackets = true;

  networking.firewall.allowedTCPPorts = [ 22 53 80 443 853 ];
  networking.firewall.allowedUDPPorts = [ 53 51820 ];
  networking.firewall.interfaces.ens3.allowedTCPPorts = [ 123 ];

  environment.etc."nftables.conf".source =
    let starts = config.systemd.services.nftables.serviceConfig.ExecStart;
    in assert (lib.length starts) == 2; lib.elemAt starts 1;

  debianControl = ''
    Architecture: all
    Description: service-firewall
    Maintainer: Erry <${config.email}>
    Package: service-firewall
    Version: 0.1.0-1
  '';

  installScript = lib.readFile ./install.sh;
}
