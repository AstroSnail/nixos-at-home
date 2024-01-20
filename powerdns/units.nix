{ config, pkgs, ... }@args:

let
  zone-file = pkgs.writeText "astrosnail.pt.eu.org.zone"
    (builtins.import ./astrosnail.pt.eu.org.zone.nix args);

  configDir =
    pkgs.writeTextDir "pdns.conf" config.services.powerdns.extraConfig;

in {
  systemd.services = {
    pdns.wants = [ "pdns-sqlite3-setup.service" ];

    pdns-sqlite3-setup = {
      description = "PowerDNS SQLite3 database setup";
      before = [ "pdns.service" ];
      path = [ pkgs.pdns pkgs.sqlite ];
      unitConfig.ConditionPathExists = "!/var/lib/pdns/gsqlite3.sqlite";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir --parents /var/lib/pdns
        chmod go-rwx /var/lib/pdns
        sqlite3 -init ${./sqlite-init.txt} /var/lib/pdns/gsqlite3.sqlite
        pdnsutil --config-dir=${configDir} load-zone astrosnail.pt.eu.org ${zone-file}
        pdnsutil --config-dir=${configDir} secure-zone astrosnail.pt.eu.org
        pdnsutil --config-dir=${configDir} set-nsec3 astrosnail.pt.eu.org '1 0 0 -' narrow
        pdnsutil --config-dir=${configDir} rectify-all-zones
        sqlite3 /var/lib/pdns/gsqlite3.sqlite "analyze;"
        chown --recursive pdns: /var/lib/pdns
      '';
    };

    pdns-update-zone = {
      description = "PowerDNS SQLite3 zone update from zonefile";
      after = [ "pdns-sqlite3-setup.service" ];
      wants = [ "pdns-sqlite3-setup.service" ];
      path = [ pkgs.pdns pkgs.sqlite ];
      unitConfig.ConditionPathExists = "/var/lib/pdns/gsqlite3.sqlite";
      serviceConfig.Type = "oneshot";
      script = ''
        pdnsutil --config-dir=${configDir} load-zone astrosnail.pt.eu.org ${zone-file}
        pdnsutil --config-dir=${configDir} rectify-all-zones
        sqlite3 /var/lib/pdns/gsqlite3.sqlite "analyze;"
      '';
    };

    pdns-rollover-zsk-phase1 = {
      description = "PowerDNS DNSSEC ZSK rollover: new DNSKEY";
      path = [ pkgs.pdns pkgs.sqlite ];
      unitConfig.ConditionPathExists = "/var/lib/pdns/rollover-zsk.txt";
      serviceConfig.Type = "oneshot";
      script = ''
        echo 'Current ZSK:'
        cat /var/lib/pdns/rollover-zsk.txt
        pdnsutil --config-dir=${configDir} add-zone-key astrosnail.pt.eu.org zsk inactive published ed25519 >/var/lib/pdns/rollover-zsk-new.txt
        echo 'Adding ZSK:'
        cat /var/lib/pdns/rollover-zsk-new.txt
        pdnsutil --config-dir=${configDir} rectify-all-zones
        sqlite3 /var/lib/pdns/gsqlite3.sqlite "analyze;"
      '';
    };
    pdns-rollover-zsk-phase2 = {
      description = "PowerDNS DNSSEC ZSK rollover: new RRSIGs";
      path = [ pkgs.pdns pkgs.sqlite ];
      unitConfig.ConditionPathExists = [
        "/var/lib/pdns/rollover-zsk.txt"
        "/var/lib/pdns/rollover-zsk-new.txt"
      ];
      serviceConfig.Type = "oneshot";
      script = ''
        zskOld=$(cat /var/lib/pdns/rollover-zsk.txt)
        echo 'Deactivating ZSK:'
        cat /var/lib/pdns/rollover-zsk.txt
        zskNew=$(cat /var/lib/pdns/rollover-zsk-new.txt)
        echo 'Activating ZSK:'
        cat /var/lib/pdns/rollover-zsk-new.txt
        pdnsutil --config-dir=${configDir} activate-zone-key astrosnail.pt.eu.org "$zskNew"
        pdnsutil --config-dir=${configDir} deactivate-zone-key astrosnail.pt.eu.org "$zskOld"
        pdnsutil --config-dir=${configDir} rectify-all-zones
        sqlite3 /var/lib/pdns/gsqlite3.sqlite "analyze;"
      '';
    };
    pdns-rollover-zsk-phase3 = {
      description = "PowerDNS DNSSEC ZSK rollover: DNSKEY removal";
      path = [ pkgs.pdns pkgs.sqlite ];
      unitConfig.ConditionPathExists = [
        "/var/lib/pdns/rollover-zsk.txt"
        "/var/lib/pdns/rollover-zsk-new.txt"
      ];
      serviceConfig.Type = "oneshot";
      script = ''
        zskOld=$(cat /var/lib/pdns/rollover-zsk.txt)
        echo 'Removing ZSK:'
        cat /var/lib/pdns/rollover-zsk.txt
        pdnsutil --config-dir=${configDir} remove-zone-key astrosnail.pt.eu.org "$zskOld"
        pdnsutil --config-dir=${configDir} rectify-all-zones
        sqlite3 /var/lib/pdns/gsqlite3.sqlite "analyze;"
        mv /var/lib/pdns/rollover-zsk-new.txt /var/lib/pdns/rollover-zsk.txt
        echo 'Current ZSK:'
        cat /var/lib/pdns/rollover-zsk.txt
      '';
    };
    pdns-rollover-ksk-phase1 = {
      description = "PowerDNS DNSSEC KSK rollover: new DNSKEY";
      path = [ pkgs.pdns pkgs.sqlite ];
      unitConfig.ConditionPathExists = "/var/lib/pdns/rollover-ksk.txt";
      serviceConfig.Type = "oneshot";
      script = ''
        echo 'Current KSK:'
        cat /var/lib/pdns/rollover-ksk.txt
        pdnsutil --config-dir=${configDir} add-zone-key astrosnail.pt.eu.org ksk active published ed25519 >/var/lib/pdns/rollover-ksk-new.txt
        echo 'Adding KSK:'
        cat /var/lib/pdns/rollover-ksk-new.txt
        pdnsutil --config-dir=${configDir} rectify-all-zones
        sqlite3 /var/lib/pdns/gsqlite3.sqlite "analyze;"
      '';
    };
    pdns-rollover-ksk-phase2 = {
      description = "PowerDNS DNSSEC KSK rollover: DNSKEY removal";
      path = [ pkgs.pdns pkgs.sqlite ];
      unitConfig.ConditionPathExists = [
        "/var/lib/pdns/rollover-ksk.txt"
        "/var/lib/pdns/rollover-ksk-new.txt"
      ];
      serviceConfig.Type = "oneshot";
      script = ''
        kskOld=$(cat /var/lib/pdns/rollover-ksk.txt)
        echo 'Removing KSK:'
        cat /var/lib/pdns/rollover-ksk.txt
        pdnsutil --config-dir=${configDir} remove-zone-key astrosnail.pt.eu.org "$kskOld"
        pdnsutil --config-dir=${configDir} rectify-all-zones
        sqlite3 /var/lib/pdns/gsqlite3.sqlite "analyze;"
        mv /var/lib/pdns/rollover-ksk-new.txt /var/lib/pdns/rollover-ksk.txt
        echo 'Current KSK:'
        cat /var/lib/pdns/rollover-ksk.txt
      '';
    };
  };

  systemd.timers = {
    pdns-rollover-zsk-phase1 = {
      description = "PowerDNS DNSSEC ZSK rollover phase 1 timer";
      timerConfig.OnCalendar = "*-*-08";
      timerConfig.RandomizedDelaySec = "1h";
    };
    pdns-rollover-zsk-phase2 = {
      description = "PowerDNS DNSSEC ZSK rollover phase 2 timer";
      timerConfig.OnCalendar = "*-*-15";
      timerConfig.RandomizedDelaySec = "1h";
    };
    pdns-rollover-zsk-phase3 = {
      description = "PowerDNS DNSSEC ZSK rollover phase 3 timer";
      timerConfig.OnCalendar = "*-*-22";
      timerConfig.RandomizedDelaySec = "1h";
    };
    pdns-rollover-ksk-phase1 = {
      description = "PowerDNS DNSSEC KSK rollover phase 1 timer";
      timerConfig.OnCalendar = "*-01-01";
      timerConfig.RandomizedDelaySec = "24h";
    };
    pdns-rollover-ksk-phase2 = {
      description = "PowerDNS DNSSEC KSK rollover phase 2 timer";
      timerConfig.OnCalendar = "*-02-01";
      timerConfig.RandomizedDelaySec = "24h";
    };
  };

  systemd.targets.pdns-rollover = {
    description = "PowerDNS DNSSEC key rollovers";
    wantedBy = [ "timers.target" ];
    requires = [
      "pdns-rollover-zsk-phase1.timer"
      "pdns-rollover-zsk-phase2.timer"
      "pdns-rollover-zsk-phase3.timer"
      "pdns-rollover-ksk-phase1.timer"
      "pdns-rollover-ksk-phase2.timer"
    ];
    after = [
      "pdns-rollover-zsk-phase1.timer"
      "pdns-rollover-zsk-phase2.timer"
      "pdns-rollover-zsk-phase3.timer"
      "pdns-rollover-ksk-phase1.timer"
      "pdns-rollover-ksk-phase2.timer"
    ];
  };
}
