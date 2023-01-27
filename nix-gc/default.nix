{
  nix.gc.automatic = true;
  nix.gc.dates = "03:15";
  nix.gc.randomizedDelaySec = "45min";
  nix.gc.options = "--delete-old";

  installScript = builtins.readFile ./install.sh;
}
