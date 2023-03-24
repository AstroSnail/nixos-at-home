{ config, lib, ... }:

{
  security.dhparams.stateful = false;
  security.dhparams.params.nginx = { };

  services.nginx.enable = true;
  services.nginx.recommendedBrotliSettings = true;
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.recommendedTlsSettings = true;
  services.nginx.serverNamesHashBucketSize = 128;
  services.nginx.serverTokens = true;
  #services.nginx.sslCiphers = "";
  services.nginx.sslDhparam = config.security.dhparams.params.nginx.path;
  services.nginx.sslProtocols = "TLSv1.3";
  services.nginx.virtualHosts = let
    listen-addrs = [
      config.this-host.ipv4
      "[${config.this-host.ipv6}]"
      "[${config.this-host.wg-addr}]"
      "[${config.this-host.yggd-addr}]"
    ];
    listeners-addr = lib.concatMap (addr: [
      {
        inherit addr;
        port = 80;
      }
      {
        inherit addr;
        port = 443;
        ssl = true;
      }
    ]) listen-addrs;
    listeners-onion = [{ unix = "onion.socket"; }];
    listeners-onion-https = [{
      unix = "onion-https.socket";
      ssl = true;
    }];
    locations = {
      "= /dns-query".proxyPass = "http://[::1]";
      "/".return = "404";
    };
    sslCertificate = "/var/lib/acme/astrosnail/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/astrosnail/key.pem";
    headers = ''
      add_header Content-Security-Policy "default-src 'none'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'; sandbox; upgrade-insecure-requests" always;
      add_header Referrer-Policy "no-referrer" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header X-Frame-Options "deny" always;
      expires 1h;
    '';
    inet-headers = ''
      add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
      add_header Onion-Location "http://www.astroslomofimguyolej7mlaofxbmczuwepljo5h5vjldxmy3me6mjid.onion" always;
    '';
  in {
    "@" = {
      serverName = "astrosnail.pt.eu.org";
      default = true;
      forceSSL = true;
      globalRedirect = "www.astrosnail.pt.eu.org";
      listen = listeners-addr;
      inherit sslCertificate sslCertificateKey;
      extraConfig = headers + inet-headers;
    };
    "onion" = {
      serverName =
        "astroslomofimguyolej7mlaofxbmczuwepljo5h5vjldxmy3me6mjid.onion";
      default = true;
      # don't force https
      addSSL = true;
      listen = listeners-onion ++ listeners-onion-https;
      inherit sslCertificate sslCertificateKey;
      # globalRedirect always redirects to https if it's enabled
      locations."/".return =
        "301 $scheme://www.astroslomofimguyolej7mlaofxbmczuwepljo5h5vjldxmy3me6mjid.onion$request_uri";
      extraConfig = headers;
    };
    "www" = {
      serverName = "www.astrosnail.pt.eu.org";
      forceSSL = true;
      listen = listeners-addr;
      inherit locations sslCertificate sslCertificateKey;
      extraConfig = headers + inet-headers;
    };
    "www.onion" = {
      serverName =
        "www.astroslomofimguyolej7mlaofxbmczuwepljo5h5vjldxmy3me6mjid.onion";
      addSSL = true;
      listen = listeners-onion ++ listeners-onion-https;
      inherit locations sslCertificate sslCertificateKey;
      extraConfig = headers;
    };
  };
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
}
