{ config, lib, pkgs, ... }:

{
  systemd.services.acme-astrosnail.wants = [ "acme-ocsp-astrosnail.service" ];
  systemd.targets.acme-finished-astrosnail.requires =
    [ "acme-ocsp-astrosnail.service" ];
  systemd.targets.acme-finished-astrosnail.after =
    [ "acme-ocsp-astrosnail.service" ];

  systemd.services.acme-ocsp-astrosnail = {
    description = "OCSP response fetcher for astrosnail";
    wants = [ "acme-astrosnail.service" ];
    after = [ "acme-astrosnail.service" ];
    path = [ pkgs.openssl ];
    unitConfig.ConditionPathExists = [
      "/var/lib/acme/astrosnail/chain.pem"
      "/var/lib/acme/astrosnail/fullchain.pem"
    ];
    serviceConfig.Type = "oneshot";
    script = ''
      # suboptimal: issuer is already part of fullchain, url is already in cert
      openssl ocsp -issuer /var/lib/acme/astrosnail/chain.pem -cert /var/lib/acme/astrosnail/fullchain.pem -no_nonce -respout /var/lib/acme/astrosnail/ocsp.der -url http://r3.o.lencr.org
      chown acme: /var/lib/acme/astrosnail/ocsp.der
      chmod 640 /var/lib/acme/astrosnail/ocsp.der
    '';
    postStart = ''
      systemctl --no-block try-reload-or-restart ${
        lib.escapeShellArgs config.security.acme.certs.astrosnail.reloadServices
      }
    '';
  };

  systemd.timers.acme-ocsp-astrosnail = {
    description = "OCSP response fetch timer for astrosnail";
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "daily";
    timerConfig.RandomizedDelaySec = "12h";
  };
}
