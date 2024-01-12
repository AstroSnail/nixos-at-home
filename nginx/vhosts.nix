{ config, lib, ... }:

{
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
    listeners-onion = [{ addr = "unix:/run/nginx/onion.socket"; }];
    listeners-onion-https = [{
      addr = "unix:/run/nginx/onion-https.socket";
      ssl = true;
    }];
    sslCertificate = "/var/lib/acme/astrosnail/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/astrosnail/key.pem";

    locations = {
      "= /dns-query".proxyPass = "http://[::1]";
      "/".return = "404";
    };
    headers = ''
      add_header Content-Security-Policy "default-src 'none'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'; sandbox; upgrade-insecure-requests" always;
      add_header Referrer-Policy "no-referrer" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header X-Frame-Options "deny" always;
      expires 1h;
    '';
    headers-inet = ''
      add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
      add_header Onion-Location "http://astroslomofimguyolej7mlaofxbmczuwepljo5h5vjldxmy3me6mjid.onion" always;
    '';

  in {
    "@" = {
      serverName = "astrosnail.pt.eu.org";
      default = true;
      forceSSL = true;
      listen = listeners-addr;
      inherit locations sslCertificate sslCertificateKey;
      extraConfig = headers + headers-inet;
    };
    "onion" = {
      serverName =
        "astroslomofimguyolej7mlaofxbmczuwepljo5h5vjldxmy3me6mjid.onion";
      default = true;
      # don't force https
      addSSL = true;
      listen = listeners-onion ++ listeners-onion-https;
      inherit locations sslCertificate sslCertificateKey;
      extraConfig = headers;
    };
  };
}
