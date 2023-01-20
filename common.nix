{ config, lib, ... }: {
  # skip assertions about bootability
  boot.isContainer = lib.mkDefault true;

  # skip warning about state versions
  system.stateVersion = lib.mkDefault config.system.nixos.release;

  networking.hostName = "sea";
  networking.domain = "astrosnail.pt.eu.org";
}
