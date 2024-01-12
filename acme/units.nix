{ config, lib, pkgs, ... }:

lib.mkMerge [
  {
    systemd.services = let
      account-configs =
        config.lib.acme.account-configs config.security.acme.certs;
      dependantService = hash: cert:
        lib.nameValuePair "acme-${cert}" {
          requires = [ "acme-account-${hash}.target" ];
        };
      dependantServices = hash: confs:
        lib.lists.map (conf: dependantService hash conf.cert) (lib.tail confs);
      allServices =
        lib.concatLists (lib.mapAttrsToList dependantServices account-configs);
    in lib.listToAttrs allServices;
  }
  {

    systemd.targets.acme-finished-astrosnail.requires =
      [ "acme-ocsp-astrosnail.service" ];
    systemd.targets.acme-finished-astrosnail.after =
      [ "acme-ocsp-astrosnail.service" ];
    systemd.timers.acme-astrosnail.timerConfig.Unit =
      lib.mkForce "acme-finished-astrosnail.target";

    systemd.services.acme-ocsp-astrosnail = {
      description = "OCSP response fetcher for astrosnail";
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
          lib.escapeShellArgs
          config.security.acme.certs.astrosnail.reloadServices
        }
      '';
    };
  }
]
