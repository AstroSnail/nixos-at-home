{ config, lib, ... }:

{
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
