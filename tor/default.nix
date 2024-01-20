{ config, lib, ... }:

{
  services.tor.enable = true;
  services.tor.settings = {
    HiddenServiceNonAnonymousMode = true;
    Sandbox = true;
  };
  services.tor.relay.onionServices.astroslomofimguy = {
    map = lib.lists.map (port: {
      inherit port;
      target = {
        inherit port;
        addr = "[${config.this-host.ipv6}]";
      };
    }) [ 22 53 853 ] ++ [
      {
        port = 80;
        target = { unix = "/run/nginx/onion.socket"; };
      }
      {
        port = 443;
        target = { unix = "/run/nginx/onion-https.socket"; };
      }
    ];
    secretKey =
      "/var/lib/tor/onion/astroslomofimguyolej7mlaofxbmczuwepljo5h5vjldxmy3me6mjid.onion/hs_ed25519_secret_key";
    settings.HiddenServiceSingleHopMode = true;
  };

  systemd.services.tor = {
    # tor bugs whenever nginx restarts, needing a restart as well
    # not ideal because tor can still be usefully up when nginx is down
    # (e.g. ssh, dns over tcp/tls)
    partOf = [ "nginx.service" ];
    serviceConfig.BindReadOnlyPaths =
      [ "/run/nginx/onion.socket" "/run/nginx/onion-https.socket" ];
  };

  debianControl = ''
    Architecture: all
    Description: service-tor
    Maintainer: Erry <${config.email}>
    Package: service-tor
    Version: 0.1.0-1
  '';

  installScript = lib.readFile ./install.sh;
  postInstallScript = lib.readFile ./postinst.sh;
}
