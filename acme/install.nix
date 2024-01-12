{ config, lib, ... }:

{
  installScript = let
    certs = lib.attrNames config.security.acme.certs;
    certs-str = lib.concatStringsSep " " certs;

    account-configs =
      config.lib.acme.account-configs config.security.acme.certs;

    account-hashes = lib.attrNames account-configs;
    account-hashes-str = lib.concatStringsSep " " account-hashes;

    text = lib.readFile ./install.sh;

  in lib.replaceStrings [ "###CERTS###" "###ACCOUNTS###" ] [
    certs-str
    account-hashes-str
  ] text;
}
