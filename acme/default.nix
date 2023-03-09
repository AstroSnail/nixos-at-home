{ config, lib, pkgs, ... }:

{
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "astrosnail@protonmail.com";
  security.acme.defaults.dnsProvider = "rfc2136";
  security.acme.defaults.credentialsFile =
    pkgs.writeText "credentials.txt" "RFC2136_NAMESERVER=127.0.0.1";
  security.acme.defaults.ocspMustStaple = true;
  #security.acme.defaults.reloadServices = [ ];
  security.acme.certs.astrosnail.domain = "astrosnail.pt.eu.org";
  security.acme.certs.astrosnail.extraDomainNames =
    [ "*.astrosnail.pt.eu.org" ];

  debianControl = ''
    Architecture: all
    Description: service-acme
    Maintainer: Erry <astrosnail@protonmail.com>
    Package: service-acme
    Version: 0.1.0-1
  '';

  installScript = let

    # generally simplified copy of functions in the nixos module
    mkHash = val: lib.substring 0 20 (builtins.hashString "sha256" val);
    mkAccountHash = data:
      mkHash "${builtins.toString data.server} ${data.keyType} ${data.email}";
    certToConfig = cert: data: {
      inherit cert;
      accountHash = mkAccountHash data;
    };
    certConfigs = lib.mapAttrs certToConfig config.security.acme.certs;
    account-configs =
      lib.groupBy (conf: conf.accountHash) (lib.attrValues certConfigs);
    account-certs-tail =
      lib.mapAttrs (_: confs: builtins.map (conf: conf.cert) (lib.tail confs))
      account-configs;

    certs = lib.attrNames certConfigs;
    certs-str-of = certs: lib.concatStringsSep " " certs;
    certs-str = certs-str-of certs;

    account-hashes = lib.attrNames account-configs;
    account-hashes-str = lib.concatStringsSep " " account-hashes;

    account-required-by = builtins.map (hash:
      "    (${hash}) required_by='${
            certs-str-of account-certs-tail.${hash}
          }';;") account-hashes;
    account-required-by-str = lib.concatStringsSep "\n" account-required-by;

    text = lib.readFile ./install.sh;

  in lib.replaceStrings [ "###CERTS###" "###ACCOUNTS###" "###REQUIREDBY###" ] [
    certs-str
    account-hashes-str
    account-required-by-str
  ] text;
}
