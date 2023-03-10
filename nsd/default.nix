{ config, lib, pkgs, ... }:

let
  nsdPkg =
    lib.substring 0 53 config.systemd.services.nsd.serviceConfig.ExecStart;
  nsdEnv =
    lib.substring 69 51 config.systemd.services.nsd.serviceConfig.ExecStart;

in {
  services.nsd.enable = true;
  services.nsd.interfaces = [
    "146.59.231.219"
    "2001:41d0:304:200::4150"
    "207:f201:452c:4b9b:64a7:8afe:4620:1ede"
    "fd57:337f:9040:1::5ea"
  ];
  services.nsd.identity = config.networking.fqdnOrHostName;
  services.nsd.nsid = "ascii_" + config.networking.fqdnOrHostName;
  #services.nsd.serverCount = 1;
  services.nsd.hideVersion = false;
  #services.nsd.roundRobin = true;
  services.nsd.ratelimit.enable = true;
  services.nsd.remoteControl.enable = true;
  services.nsd.zones."astrosnail.pt.eu.org." = {
    data = lib.readFile ./astrosnail.pt.eu.org.zone;
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

  systemd.services.nsd-control-setup = {
    description = "NSD remote control setup";
    before = [ "nsd.service" ];
    wantedBy = [ "nsd.service" ];
    path = [ pkgs.openssl ];
    script = ''
      mkdir --parents /etc/nsd
      ${nsdPkg}/sbin/nsd-control-setup -d /etc/nsd
    '';
    serviceConfig.Type = "oneshot";
  };

  systemd.services.nsd-dnssec = {
    after = [ "nsd.service" ];
    before = lib.mkForce [ ];
    postStop =
      lib.mkForce "${nsdPkg}/sbin/nsd-control -c ${nsdEnv}/nsd.conf reload";
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/var/lib/nsd/zones";
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      bind = self.callPackage ./bind.nix { python3 = self.python39; };
    })
  ];

  debianControl = lib.readFile ./control.txt;
  installScript = lib.readFile ./install.sh;
}
