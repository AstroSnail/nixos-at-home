{ config, lib, ... }:

let
  email-split = lib.splitString "@" config.email;
  email-local-dots =
    lib.replaceStrings [ "." ] [ "\\." ] (lib.elemAt email-split 0);
  email-domain = lib.elemAt email-split 1;
  email-soa = assert (lib.length email-split) == 2;
    "${email-local-dots}.${email-domain}.";

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
    in if value != null && recordData ? ${key} then
      with recordData.${key}; ''
        ${prefix}${host} ${type} ${qvalue}
      ''
    else
      "";
  host-to-zone = host: data:
    lib.concatStrings (lib.mapAttrsToList (key-to-zone host) data);
  hosts-to-zone = hosts:
    lib.concatStrings (lib.mapAttrsToList host-to-zone hosts);

in ''
  $ORIGIN astrosnail.pt.eu.org.
  $TTL 1h

  ; info
            ;                       SERIAL REFRESH RETRY EXPIRE MINIMUM
  @         SOA    sea ${email-soa} 0      3h      1h    1w     1h
            CAA    128 issue        "letsencrypt.org; accounturi=https://acme-v02.api.letsencrypt.org/acme/acct/1001995317; validationmethods=dns-01"
            CAA      0 issuewild    ";"
            CAA      0 iodef        "mailto:${config.email}"
            CAA      0 contactemail "${config.email}"
            RP     ${email-soa} erry
            TXT    "keybase-site-verification=HNPj0etgb3YWy5gfHR9xtMucE44Lh5siUnf4UdQY45g"
  _ens      TXT    "a=0x4650264Dd8Fb4e32A88168E6206e0779D11800c7"
  _validation-contactemail  TXT  "${config.email}"
  erry      TXT    "Erry! <${config.email}>"
  onion     CNAME  astroslomofimguyolej7mlaofxbmczuwepljo5h5vjldxmy3me6mjid.onion.

  ; hosts
  ${hosts-to-zone config.hosts}

  ; services
  _http._tcp   SRV  0 0 80 sea
  _https._tcp  SRV  0 0 443 sea
            ; as long as ALIAS/ANAME still isn't a thing, and as long as web
            ; browsers don't support alternative service specifications, a
            ; couple extra A/AAAA records are still necessary
  @         A      ${config.this-host.ipv4}
            AAAA   ${config.this-host.ipv6}
            ; if the nameservers change, i'll have to enter the nic.eu.org
            ; control panel anyway to update their glue records, so linking the
            ; hostnames directly in the NS records imposes no extra effort.
            ; i don't have a second nameserver; use sea again.
            ; (but under a different name)
            ; dns specifically is hard to host at home, so i won't.
            NS     sea
            NS     vps-04b3828b.vps.ovh.net.

  ; experimental
  ; powerdns live-signing signs wildcards
  ; but what about offline-signing?
  ;*         CNAME  sea

  ; funny
  ; keep in mind: a CNAME is not a delegation point
  ; i have authority over this CNAME record
  ; (but, incidentally, not the domain it points to)
  so-you-thought-you-could-just-have-a-subdomain-for-yourself-huh.you-wanted-to-show-the-whole-world-that-you-can-just-ask-for-it.well-let-me-teach-you-a-little-something-from-round-these-parts.one-does-not-simply-get-a-subdomain-from.astrosnail.pt.eu.org.  CNAME  juhu.is.not.malic.ee. ;juhu.internet-box.ch.
''
