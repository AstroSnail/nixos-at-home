{ config, lib, pkgs, ... }:

{
  services.tor.enable = true;
  services.tor.settings = {
    HiddenServiceNonAnonymousMode = true;
    Sandbox = true;
  };
  services.tor.relay.onionServices.astrosnail = {
    map = [ 22 ];
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
