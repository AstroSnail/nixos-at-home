{ config, ... }:

{
  services.dnsdist.listenAddress = config.this-host.ipv4;
  services.dnsdist.extraConfig = ''
    addLocal('[${config.this-host.ipv6}]')
    addLocal('[${config.this-host.wg-addr}]')
    addLocal('[${config.this-host.yggd-addr}]')

    addDOHLocal('[::1]')

    local certFile = '/var/lib/acme/astrosnail/fullchain.pem'
    local keyFile = '/var/lib/acme/astrosnail/key.pem'
    local options = {
      ocspResponses = { '/var/lib/acme/astrosnail/ocsp.der' },
      minTLSVersion = 'tls1.3',
      additionalAddresses = {
        -- dnsdist is buggy and needs ports here
        '[${config.this-host.ipv6}]:853',
        '[${config.this-host.wg-addr}]:853',
        '[${config.this-host.yggd-addr}]:853',
      },
    }
    addTLSLocal('${config.this-host.ipv4}', certFile, keyFile, options)

    newServer({
      address = '[::1]',
      checkName = 'astrosnail.pt.eu.org',
      checkType = 'SOA',
    })

    setACL({ '0.0.0.0/0', '::/0' })

    addAction(OpcodeRule(DNSOpcode.Update), RCodeAction(DNSRCode.NOTIMP, { ra = false }))
  '';
}
