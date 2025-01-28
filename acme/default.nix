{ config, pkgs, ... }:

{
  imports = [
    ./account-configs.nix
    ./install.nix
    ./units.nix
  ];

  security.acme.acceptTerms = true;
  security.acme.maxConcurrentRenewals = 1;
  security.acme.defaults.email = config.email;
  security.acme.defaults.dnsPropagationCheck = false; # buggy fsr
  security.acme.defaults.dnsProvider = "rfc2136";
  security.acme.defaults.environmentFile = pkgs.writeText "credentials.txt" "RFC2136_NAMESERVER=[::1]:53";
  security.acme.defaults.ocspMustStaple = false; # let's encrypt no longer supports
  security.acme.defaults.server = null; # ensure account hash stays the same
  security.acme.defaults.reloadServices = [
    "dnsdist.service"
    "nginx.service"
  ];
  security.acme.certs.astrosnail = {
    domain = "astrosnail.pt.eu.org";
    extraDomainNames = [ "sea.astrosnail.pt.eu.org" ];
  };

  environment.etc."tmpfiles.d/00-acme.conf".text =
    let
      lockdir = "/run/acme/";
      user = if config.security.acme.useRoot then "root" else "acme";
    in
    ''
      d ${lockdir} 0700 ${user} - - -
      Z ${lockdir} 0700 ${user} - - -
    '';

  debianControl = ''
    Architecture: all
    Description: service-acme
    Maintainer: Erry <${config.email}>
    Package: service-acme
    Version: 0.1.0-1
  '';
}
