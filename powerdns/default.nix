{ config, lib, pkgs, ... }:

let
  # this is a very cheap config-generator
  # properly made, it should be a module with options
  value-to-conf = value:
    {
      bool = if value then "yes" else "no";
      list = lib.concatMapStringsSep "," value-to-conf value;
    }.${builtins.typeOf value} or (builtins.toString value);
  gen-line = name: value: "${name}=${value-to-conf value}";
  to-pdns-config = lib.flip lib.pipe [
    (lib.mapAttrs gen-line)
    lib.attrValues
    (lib.concatStringsSep "\n")
  ];

in {
  imports = [ ./units.nix ];

  services.powerdns.enable = true;
  services.powerdns.extraConfig = to-pdns-config {
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
