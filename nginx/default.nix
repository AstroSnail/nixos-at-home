{ config, lib, ... }:

{
  imports = [ ./vhosts.nix ];

  security.dhparams.stateful = false;
  security.dhparams.params.nginx = { };

  services.nginx.enable = true;
  services.nginx.recommendedBrotliSettings = true;
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.recommendedTlsSettings = true;
  services.nginx.recommendedZstdSettings = true;
  services.nginx.serverNamesHashBucketSize = 128;
  services.nginx.serverTokens = true;
  #services.nginx.sslCiphers = "";
  services.nginx.sslDhparam = config.security.dhparams.params.nginx.path;
  services.nginx.sslProtocols = "TLSv1.3";
  services.nginx.appendHttpConfig = ''
    ssl_stapling_file /var/lib/acme/astrosnail/ocsp.der;
  '';

  environment.etc."logrotate.d/nginx".text = ''
    /var/log/nginx/*.log {
      weekly
      su nginx nginx
      rotate 26
      compress
      delaycompress
      postrotate
        if [ -f /var/run/nginx/nginx.pid ]
        then kill -USR1 $(cat /var/run/nginx/nginx.pid)
        fi
      endscript
    }
  '';

  environment.etc."tmpfiles.d/00-nginx.conf".text = ''
    X /tmp/systemd-private-%b-nginx.service-*/tmp/nginx_*
  '';

  systemd.services.nginx = {
    wants = [ "acme-finished-astrosnail.target" ];
    after = [ "acme-finished-astrosnail.target" ];
    before = [ "tor.service" ];
    serviceConfig.SupplementaryGroups = "acme";
  };

  debianControl = ''
    Architecture: all
    Description: service-nginx
    Maintainer: Erry <${config.email}>
    Package: service-nginx
    Version: 0.1.0-1
  '';

  installScript = lib.readFile ./install.sh;
  postInstallScript = lib.readFile ./postinst.sh;
}
