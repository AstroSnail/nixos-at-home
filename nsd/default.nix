{ config, lib, ... }:

let
  nsdPkg =
    builtins.substring 0 53 config.systemd.services.nsd.serviceConfig.ExecStart;
  nsdEnv = builtins.substring 69 51
    config.systemd.services.nsd.serviceConfig.ExecStart;

in {
  services.nsd.enable = true;
  #services.nsd.interfaces = [ ];
  services.nsd.identity = config.networking.fqdnOrHostName;
  services.nsd.nsid = "ascii_" + config.networking.fqdnOrHostName;
  #services.nsd.serverCount = 1;
  services.nsd.hideVersion = false;
  #services.nsd.roundRobin = true;
  services.nsd.ratelimit.enable = true;
  services.nsd.remoteControl.enable = true;
  services.nsd.zones."astrosnail.pt.eu.org." = {
    data = builtins.readFile ./astrosnail.pt.eu.org.zone;
    dnssec = true;
    dnssecPolicy.algorithm = "ED25519";
    dnssecPolicy.ksk.keySize = 256;
    dnssecPolicy.ksk.rollPeriod = "1y";
    dnssecPolicy.ksk.prePublish = "1mo";
    dnssecPolicy.ksk.postPublish = "1mo";
    dnssecPolicy.zsk.keySize = 256;
    dnssecPolicy.zsk.rollPeriod = "1mo";
    dnssecPolicy.zsk.prePublish = "1w";
    dnssecPolicy.zsk.postPublish = "1w";
  };

  systemd.services.nsd-dnssec.postStop =
    lib.mkForce "${nsdPkg}/sbin/nsd-control -c ${nsdEnv}/nsd.conf";

  systemd.services.nsd-control-setup = {
    description = "NSD remote control setup";
    before = [ "nsd.service" ];
    wantedBy = [ "nsd.service" ];
    script = ''
      mkdir --parents /etc/nsd
      ${nsdPkg}/sbin/nsd-control-setup -d /etc/nsd
    '';
    serviceConfig.Type = "oneshot";
  };

  debianControl = builtins.readFile ./control.txt;
  installScript = builtins.readFile ./install.sh;
}
