{ config, lib, ... }:

{
  services.dnsdist.enable = true;
  services.dnsdist.extraConfig = ''
    setACL({ '0.0.0.0/0', '::/0' })

    setLocal('${config.hosts.sea.ipv4}')
    addLocal('[${config.hosts.sea.ipv6}]')
    addLocal('[${config.hosts.sea.wg-addr}]')
    addLocal('[${config.hosts.sea.yggd-addr}]')

    addDOHLocal('[::1]')

    addTLSLocal('[::1]', '/var/lib/acme/astrosnail/fullchain.pem', '/var/lib/acme/astrosnail/key.pem', {
      ocspResponses = { '/var/lib/acme/astrosnail/ocsp.der' },
      minTLSVersion = 'tls1.3',
      additionalAddresses = {
        '${config.hosts.sea.ipv4}',
        '[${config.hosts.sea.ipv6}]',
        '[${config.hosts.sea.wg-addr}]',
        '[${config.hosts.sea.yggd-addr}]'
      }
    })

    newServer({
      address = '127.0.0.1',
      checkName = 'sea.astrosnail.pt.eu.org'
    })
  '';

  systemd.services.dnsdist.serviceConfig.SupplementaryGroups = "acme";

  debianControl = ''
    Architecture: all
    Description: service-dnsdist
    Maintainer: Erry <${config.email}>
    Package: service-dnsdist
    Version: 0.1.0-1
  '';

  installScript = lib.readFile ./install.sh;
}
