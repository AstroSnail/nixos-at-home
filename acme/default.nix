{ config, lib, pkgs, ... }:

{
  imports = [ ./units.nix ];

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

  installScript = let
    # generally simplified copy of functions in the nixos module

    certs = lib.attrNames config.security.acme.certs;
    certs-str-of = certs: lib.concatStringsSep " " certs;
    certs-str = certs-str-of certs;

    mkHash = val: lib.substring 0 20 (builtins.hashString "sha256" val);
    mkAccountHash = data:
      mkHash "${builtins.toString data.server} ${data.keyType} ${data.email}";
    certToConfig = cert: data: {
      inherit cert;
      accountHash = mkAccountHash data;
    };

    certConfigs = lib.mapAttrsToList certToConfig config.security.acme.certs;
    account-configs = lib.groupBy (conf: conf.accountHash) certConfigs;

    account-hashes = lib.attrNames account-configs;
    account-hashes-str = lib.concatStringsSep " " account-hashes;

    certs-tail-of = confs:
      certs-str-of (builtins.map (conf: conf.cert) (lib.tail confs));
    account-required-by = lib.mapAttrsToList
      (hash: confs: "    (${hash}) required_by='${certs-tail-of confs}';;")
      account-configs;
    account-required-by-str = lib.concatStringsSep "\n" account-required-by;

    text = lib.readFile ./install.sh;

  in lib.replaceStrings [ "###CERTS###" "###ACCOUNTS###" "###REQUIREDBY###" ] [
    certs-str
    account-hashes-str
    account-required-by-str
  ] text;
}
