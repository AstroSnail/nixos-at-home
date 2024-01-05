{ lib, ... }:

let
  key-to-zone = host: key: value:
    let
      recordData = {
        ipv4 = {
          prefix = "";
          type = "A";
          qvalue = value;
        };
        ipv6 = {
          prefix = "";
          type = "AAAA";
          qvalue = value;
        };
        wg-addr = {
          prefix = "wireguard.";
          type = "AAAA";
          qvalue = value;
        };
        wg-pub = {
          prefix = "wireguard.";
          type = "TXT";
          qvalue = ''"${value}"'';
        };
        yggd-addr = {
          prefix = "yggdrasil.";
          type = "AAAA";
          qvalue = value;
        };
        yggd-pub = {
          prefix = "yggdrasil.";
          type = "TXT";
          qvalue = ''"${value}"'';
        };
        loc = {
          prefix = "";
          type = "LOC";
          qvalue = value;
        };
        sshfp = {
          prefix = "";
          type = "SSHFP";
          qvalue = value;
        };
      };
    in lib.optionalString (value != null && recordData ? ${key})
    (with recordData.${key}; ''
      ${prefix}${host} ${type} ${qvalue}
    '');
  host-to-zone = host: data:
    lib.concatStrings (lib.mapAttrsToList (key-to-zone host) data);
  hosts-to-zone = hosts:
    lib.concatStrings (lib.mapAttrsToList host-to-zone hosts);

in { lib.pdns = { inherit hosts-to-zone; }; }
