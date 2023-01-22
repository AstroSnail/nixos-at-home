{ config, lib, ... }:

{
  # skip assertions about bootability
  config.boot.isContainer = lib.mkDefault true;

  # skip warning about state versions
  config.system.stateVersion = lib.mkDefault config.system.nixos.release;

  # for building the app
  options.installScript = lib.mkOption { type = lib.types.str; };

  # "system-wide" config
  config.networking.hostName = "sea";
  config.networking.domain = "astrosnail.pt.eu.org";
}
