{ config, ... }:

# switch config when dnsdist hits 1.8.0
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
    }

    if false then
      options.additionalAddresses = {
        '[${config.this-host.ipv6}]',
        '[${config.this-host.wg-addr}]',
        '[${config.this-host.yggd-addr}]',
      }
      addTLSLocal('${config.this-host.ipv4}', certFile, keyFile, options)
    else
      addTLSLocal('${config.this-host.ipv4}', certFile, keyFile, options)
      addTLSLocal('[${config.this-host.ipv6}]', certFile, keyFile, options)
      addTLSLocal('[${config.this-host.wg-addr}]', certFile, keyFile, options)
      addTLSLocal('[${config.this-host.yggd-addr}]', certFile, keyFile, options)
    end

    newServer({
      address = '[::1]',
      checkName = 'sea.astrosnail.pt.eu.org',
    })

    setACL({ '0.0.0.0/0', '::/0' })

    addAction(OpcodeRule(DNSOpcode.Update), RCodeAction(DNSRCode.NOTIMP))
  '';
}
