{ config }: ''
  $ORIGIN astrosnail.pt.eu.org.
  $TTL 1h

  ;                                               SERIAL REFRESH RETRY EXPIRE MINIMUM
  @         SOA    ns1 astrosnail.protonmail.com. 0      3h      1h    1w     1h
            NS     ns1
            NS     ns2
            A      ${config.ips.sea-ipv4}
            AAAA   ${config.ips.sea-ipv6}

  ns1       A      ${config.ips.sea-ipv4}
            AAAA   ${config.ips.sea-ipv6}
  ns2       A      ${config.ips.sea-ipv4}
            AAAA   ${config.ips.sea-ipv6}

  ; hosts
  snail     A      ${config.ips.snail-ipv4}
            AAAA   ${config.ips.snail-ipv6}
  soon      A      ${config.ips.soon-ipv4}
            AAAA   ${config.ips.soon-ipv6}
  sea       A      ${config.ips.sea-ipv4}
            AAAA   ${config.ips.sea-ipv6}

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

  ; info
  @         CAA    128 issue     "letsencrypt.org"
            CAA    128 issuewild "letsencrypt.org"
            CAA      0 iodef     "mailto:astrosnail@protonmail.com"
            TXT    "keybase-site-verification=HNPj0etgb3YWy5gfHR9xtMucE44Lh5siUnf4UdQY45g"
  _ens      TXT    "a=0x4650264Dd8Fb4e32A88168E6206e0779D11800c7"

  ; funny
  so-you-thought-you-could-just-have-a-subdomain-for-yourself-huh.you-wanted-to-show-the-whole-world-that-you-can-just-ask-for-it.well-let-me-teach-you-a-little-something-from-round-these-parts.one-does-not-simply-get-a-subdomain-from.astrosnail.pt.eu.org.  CNAME  juhu.is.not.malic.ee. ;juhu.internet-box.ch.
''
