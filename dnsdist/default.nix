{ config, lib, ... }:

{
  # switch config when dnsdist hits 1.8.0
  services.dnsdist.enable = true;
  services.dnsdist.extraConfig = ''
    setACL({ '0.0.0.0/0', '::/0' })

    setLocal('${config.this-host.ipv4}')
    addLocal('[${config.this-host.ipv6}]')
    addLocal('[${config.this-host.wg-addr}]')
    addLocal('[${config.this-host.yggd-addr}]')

    addDOHLocal('[::1]')
  '' + (if false then ''
    addTLSLocal('${config.this-host.ipv4}', '/var/lib/acme/astrosnail/fullchain.pem', '/var/lib/acme/astrosnail/key.pem', {
      ocspResponses = { '/var/lib/acme/astrosnail/ocsp.der' },
      minTLSVersion = 'tls1.3',
      additionalAddresses = {
        '[${config.this-host.ipv6}]',
        '[${config.this-host.wg-addr}]',
        '[${config.this-host.yggd-addr}]'
      }
    })
  '' else ''
    certFile = '/var/lib/acme/astrosnail/fullchain.pem'
    keyFile = '/var/lib/acme/astrosnail/key.pem'
    options = {
      ocspResponses = { '/var/lib/acme/astrosnail/ocsp.der' },
      minTLSVersion = 'tls1.3'
    }
    addTLSLocal('${config.this-host.ipv4}', certFile, keyFile, options)
    addTLSLocal('[${config.this-host.ipv6}]', certFile, keyFile, options)
    addTLSLocal('[${config.this-host.wg-addr}]', certFile, keyFile, options)
    addTLSLocal('[${config.this-host.yggd-addr}]', certFile, keyFile, options)
  '') + ''
    newServer({
      address = '[::1]',
      checkName = 'sea.astrosnail.pt.eu.org'
    })
  '';

  systemd.services.dnsdist = {
    wants = [ "acme-finished-astrosnail.target" ];
    after = [ "acme-finished-astrosnail.target" ];
    serviceConfig.SupplementaryGroups = "acme";
  };

  debianControl = ''
    Architecture: all
    Description: service-dnsdist
    Maintainer: Erry <${config.email}>
    Package: service-dnsdist
    Version: 0.1.0-1
  '';

  installScript = lib.readFile ./install.sh;
}
