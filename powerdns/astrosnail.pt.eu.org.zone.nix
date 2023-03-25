{ config, lib, ... }:

# [1]: https://datatracker.ietf.org/doc/draft-ietf-dnsop-svcb-https/
#
# [2]: if the nameservers change, i'll have to enter the nic.eu.org control
#      panel anyway to update their glue records, so linking the hostnames
#      directly in the NS records imposes no extra effort.
#      i don't have a second nameserver; use sea again.
#      (but under a different name)
#      dns specifically is hard to host at home, so i won't.
#
# [3]: powerdns live-signing signs wildcards
#      but what about offline-signing?
#
# [4]: keep in mind: a CNAME is not a delegation point
#      i have authority over this CNAME record
#      (but, incidentally, not the domain it points to)
#      in any case, take care to ask them about things like hsts

let
  email-split = lib.splitString "@" config.email;
  email-local-dots =
    lib.replaceStrings [ "." ] [ "\\." ] (lib.elemAt email-split 0);
  email-domain = lib.elemAt email-split 1;
  email-soa = assert (lib.length email-split) == 2;
    "${email-local-dots}.${email-domain}.";

in ''
  $ORIGIN astrosnail.pt.eu.org.
  $TTL 1h

  ; info
  ;                                 SERIAL REFRESH RETRY EXPIRE MINIMUM
  @         SOA    sea ${email-soa} 0      3h      1h    1w     1h
            CAA    128 issue "letsencrypt.org; accounturi=https://acme-v02.api.letsencrypt.org/acme/acct/1001995317; validationmethods=dns-01"
            CAA      0 issuewild ";"
            CAA      0 iodef "mailto:${config.email}"
            CAA      0 contactemail "${config.email}"
            RP     ${email-soa} erry
            TXT    "keybase-site-verification=HNPj0etgb3YWy5gfHR9xtMucE44Lh5siUnf4UdQY45g"
  _ens      TXT    "a=0x4650264Dd8Fb4e32A88168E6206e0779D11800c7"
  _validation-contactemail  TXT  "${config.email}"
  erry      TXT    "Erry! <${config.email}>"
  onion     CNAME  astroslomofimguyolej7mlaofxbmczuwepljo5h5vjldxmy3me6mjid.onion.

  ; hosts
  ${config.lib.pdns.hosts-to-zone config.hosts}

  ; services [1]
  @         A      ${config.this-host.ipv4}
            AAAA   ${config.this-host.ipv6}
            ; [2]
            NS     sea
            NS     vps-04b3828b.vps.ovh.net.
  _http._tcp   SRV  0 0 80 sea
  _https._tcp  SRV  0 0 443 sea

  ; experimental [3]
  ;*         CNAME  sea

  ; funny [4]
  so-you-thought-you-could-just-have-a-subdomain-for-yourself-huh.you-wanted-to-show-the-whole-world-that-you-can-just-ask-for-it.well-let-me-teach-you-a-little-something-from-round-these-parts.one-does-not-simply-get-a-subdomain-from.astrosnail.pt.eu.org.  CNAME  juhu.is.not.malic.ee. ;juhu.internet-box.ch.
''
