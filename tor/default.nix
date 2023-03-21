{ config, lib, ... }:

{
  services.tor.enable = true;
  services.tor.settings = {
    HiddenServiceNonAnonymousMode = true;
    Sandbox = true;
  };
  services.tor.relay.onionServices.astroslomofimguy = {
    map = [ 22 ];
    secretKey =
      "/var/lib/tor/onion/astroslomofimguyolej7mlaofxbmczuwepljo5h5vjldxmy3me6mjid.onion/hs_ed25519_secret_key";
    settings.HiddenServiceSingleHopMode = true;
  };

  debianControl = ''
    Architecture: all
    Description: service-tor
    Maintainer: Erry <${config.email}>
    Package: service-tor
    Version: 0.1.0-1
  '';

  installScript = lib.readFile ./install.sh;
}
