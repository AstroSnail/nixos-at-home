{ lib, ... }:

let
  key-to-zone = host: key: value:
    let
      recordData = {
        ipv4.prefix = "";
        ipv4.type = "A";
        ipv4.qvalue = value;

        ipv6.prefix = "";
        ipv6.type = "AAAA";
        ipv6.qvalue = value;

        wg-addr.prefix = "wireguard.";
        wg-addr.type = "AAAA";
        wg-addr.qvalue = value;

        wg-pub.prefix = "wireguard.";
        wg-pub.type = "TXT";
        wg-pub.qvalue = ''"${value}"'';

        yggd-addr.prefix = "yggdrasil.";
        yggd-addr.type = "AAAA";
        yggd-addr.qvalue = value;

        yggd-pub.prefix = "yggdrasil.";
        yggd-pub.type = "TXT";
        yggd-pub.qvalue = ''"${value}"'';

        loc.prefix = "";
        loc.type = "LOC";
        loc.qvalue = value;

        sshfp.prefix = "";
        sshfp.type = "SSHFP";
        sshfp.qvalue = value;
      };
    in lib.optionalString (recordData ? ${key} && value != null)
    (with recordData.${key}; ''
      ${prefix}${host} ${type} ${qvalue}
    '');
  host-to-zone = host: data:
    lib.concatStrings (lib.mapAttrsToList (key-to-zone host) data);
  hosts-to-zone = hosts:
    lib.concatStrings (lib.mapAttrsToList host-to-zone hosts);

in { lib.pdns = { inherit hosts-to-zone; }; }
