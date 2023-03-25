{ config, pkgs, ... }:

{
  imports = [ ./install.nix ./units.nix ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = config.email;
  security.acme.defaults.dnsProvider = "rfc2136";
  security.acme.defaults.credentialsFile =
    pkgs.writeText "credentials.txt" "RFC2136_NAMESERVER=[::1]";
  security.acme.defaults.ocspMustStaple = true;
  security.acme.defaults.reloadServices = [ "dnsdist.service" "nginx.service" ];
  security.acme.certs.astrosnail = {
    domain = "astrosnail.pt.eu.org";
    extraDomainNames =
      [ "sea.astrosnail.pt.eu.org" "www.astrosnail.pt.eu.org" ];
  };

  debianControl = ''
    Architecture: all
    Description: service-acme
    Maintainer: Erry <${config.email}>
    Package: service-acme
    Version: 0.1.0-1
  '';
}
