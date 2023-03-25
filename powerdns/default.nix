{ config, lib, ... }:

{
  imports = [ ./gen-config.nix ./units.nix ];

  services.powerdns.enable = true;
  services.powerdns.extraConfig = config.lib.pdns.gen-config {
    local-address = "[::1]";
    # alias is incompatible with live-signing
    #expand-alias = true;
    #resolver = "127.0.0.53";
    # dnssec
    default-ksk-algorithm = "ed25519";
    default-zsk-algorithm = "ed25519";
    # rfc2136
    dnsupdate = true;
    # bind-hybrid requires disabling zone cache
    #zone-cache-refresh-interval = 0;
    # other
    #reuseport = true;
    server-id = config.networking.fqdnOrHostName;

    #launch = [ "bind" "gsqlite3" ];
    #bind-config = bind-config;
    #bind-hybrid = true;
    launch = [ "gsqlite3" ];
    gsqlite3-database = "/var/lib/pdns/gsqlite3.sqlite";
    gsqlite3-pragma-synchronous = false;
    gsqlite3-dnssec = true;
  };

  debianControl = ''
    Architecture: all
    Description: service-powerdns
    Maintainer: Erry <${config.email}>
    Package: service-powerdns
    Version: 0.1.0-1
  '';

  installScript = lib.readFile ./install.sh;
}
