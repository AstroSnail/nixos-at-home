{ config, lib, ... }:

let
  email-split = lib.splitString "@" config.email;
  email-local-dots =
    lib.replaceStrings [ "." ] [ "\\." ] (lib.elemAt email-split 0);
  email-domain = lib.elemAt email-split 1;
  email-soa = "${email-local-dots}.${email-domain}";

in ''
  $ORIGIN astrosnail.pt.eu.org.
  $TTL 1h

  ;                                  SERIAL REFRESH RETRY EXPIRE MINIMUM
  @         SOA    sea ${email-soa}. 0      3h      1h    1w     1h
            NS     sea
            NS     ns2
            A      ${config.ips.sea-ipv4}
            AAAA   ${config.ips.sea-ipv6}

  ; i don't have a second nameserver; use sea again.
  ; dns specifically is hard to host at home, so i won't.
  ; if the nameservers change, i'll have to enter the nic.eu.org control panel
  ; anyway to update their glue records, so linking the hostnames directly in
  ; the NS records imposes no additional effort.
  ns2       A      ${config.ips.sea-ipv4}
            AAAA   ${config.ips.sea-ipv6}

  ; info
  @         CAA    128 issue        "letsencrypt.org; accounturi=https://acme-v02.api.letsencrypt.org/acme/acct/1001995317; validationmethods=dns-01"
            CAA      0 issuewild    ";"
            CAA      0 iodef        "mailto:${config.email}"
            CAA      0 contactemail "${config.email}"
            TXT    "keybase-site-verification=HNPj0etgb3YWy5gfHR9xtMucE44Lh5siUnf4UdQY45g"
  _ens      TXT    "a=0x4650264Dd8Fb4e32A88168E6206e0779D11800c7"
  _validation-contactemail  TXT  "${config.email}"

  ; hosts
  snail     AAAA   ${config.ips.snail-ipv6}
  soon      A      ${config.ips.soon-ipv4}
            AAAA   ${config.ips.soon-ipv6}
            ; Portugal (centered at the Picoto da Melriça)
            LOC    39 41 40 N 8 7 50 W 595m 600000m 100m 10m
  sea       A      ${config.ips.sea-ipv4}
            AAAA   ${config.ips.sea-ipv6}
            ; OVHcloud Gravelines
            LOC    51 1 0 N 2 9 20 E 5m 500m 100m 10m

  ; subdomains
  bin       CNAME  snail
  blog      CNAME  snail
  click     CNAME  snail
  css       CNAME  snail
  git       CNAME  snail
  green     CNAME  snail
  minetest  CNAME  snail
  webgl     CNAME  snail
  www       CNAME  snail

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
