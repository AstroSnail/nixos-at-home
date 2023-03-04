{ config, lib, pkgs, ... }:

let
  sea-ipv4 = "146.59.231.219";
  sea-ipv6 = "[2001:41d0:304:200::4150]";

  bind-config = pkgs.writeText "named.conf" ''
    zone "astrosnail.pt.eu.org" {
      type native;
      file "${./astrosnail.pt.eu.org.zone}";
    };
  '';

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
  services.powerdns.enable = true;
  services.powerdns.extraConfig = to-pdns-config {
    # zero addresses are already being used
    # (is it systemd 127.0.0.53%lo???)
    local-address = [ sea-ipv4 sea-ipv6 ];
    # alias is incompatible with live-signing
    #expand-alias = true;
    #resolver = "127.0.0.53";
    # dnssec
    default-ksk-algorithm = "ed25519";
    default-zsk-algorithm = "ed25519";
    # rfc2136
    dnsupdate = true;
    # bind-hybrid requires disabling zone cache
    zone-cache-refresh-interval = 0;
    # other
    reuseport = true;
    server-id = config.networking.fqdnOrHostName;

    launch = [ "bind" "gsqlite3" ];
    bind-config = bind-config;
    bind-hybrid = true;
    gsqlite3-database = "/var/lib/pdns/gsqlite3.sqlite";
    gsqlite3-pragma-synchronous = false;
    gsqlite3-dnssec = true;
  };

  systemd.services.pdns-sqlite3-setup = {
    description = "PowerDNS SQLite3 database setup";
    before = [ "pdns.service" ];
    wantedBy = [ "pdns.service" ];
    path = [ pkgs.sqlite ];
    unitConfig.ConditionPathExists = "!/var/lib/pdns";
    script = ''
      mkdir --parents /var/lib/pdns
      sqlite3 -init ${./sqlite-init.txt} /var/lib/pdns/gsqlite3.sqlite
      sqlite3 /var/lib/pdns/gsqlite3.sqlite "insert into domains (name, type) values ('astrosnail.pt.eu.org', 'NATIVE');"
      chmod go-rwx /var/lib/pdns
      chown --recursive pdns: /var/lib/pdns
    '';
    serviceConfig.Type = "oneshot";
  };

  debianControl = lib.readFile ./control.txt;
  installScript = lib.readFile ./install.sh;
}
