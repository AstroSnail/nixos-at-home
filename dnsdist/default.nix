{ config, lib, ... }:

{
  # switch config when dnsdist hits 1.8.0
  services.dnsdist.enable = true;
  services.dnsdist.extraConfig = ''
    setACL({ '0.0.0.0/0', '::/0' })

    setLocal('${config.hosts.sea.ipv4}')
    addLocal('[${config.hosts.sea.ipv6}]')
    addLocal('[${config.hosts.sea.wg-addr}]')
    addLocal('[${config.hosts.sea.yggd-addr}]')

    addDOHLocal('[::1]')
  '' + (if false then ''
    addTLSLocal('${config.hosts.sea.ipv4}', '/var/lib/acme/astrosnail/fullchain.pem', '/var/lib/acme/astrosnail/key.pem', {
      ocspResponses = { '/var/lib/acme/astrosnail/ocsp.der' },
      minTLSVersion = 'tls1.3',
      additionalAddresses = {
        '[${config.hosts.sea.ipv6}]',
        '[${config.hosts.sea.wg-addr}]',
        '[${config.hosts.sea.yggd-addr}]'
      }
    })
  '' else ''
    certFile = '/var/lib/acme/astrosnail/fullchain.pem'
    keyFile = '/var/lib/acme/astrosnail/key.pem'
    options = {
      ocspResponses = { '/var/lib/acme/astrosnail/ocsp.der' },
      minTLSVersion = 'tls1.3'
    }
    addTLSLocal('${config.hosts.sea.ipv4}', certFile, keyFile, options)
    addTLSLocal('[${config.hosts.sea.ipv6}]', certFile, keyFile, options)
    addTLSLocal('[${config.hosts.sea.wg-addr}]', certFile, keyFile, options)
    addTLSLocal('[${config.hosts.sea.yggd-addr}]', certFile, keyFile, options)
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
