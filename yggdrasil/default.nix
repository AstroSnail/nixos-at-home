{ config, pkgs, ... }:

{
  services.yggdrasil.enable = true;
  services.yggdrasil.persistentKeys = true;
  services.yggdrasil.settings = {
    IfName = "yggdrasil0";
    Listen = [ "tcp://[::]:123" ];
    NodeInfo = { name = config.networking.fqdnOrHostName; };
    Peers = [ "tcp://[2001:818:df73:f400::abba:cad:abba]:123" ];
  };

  systemd.services.yggdrasil-activation = {
    description = "Activation script for yggdrasil";
    before = [ "yggdrasil.service" ];
    requiredBy = [ "yggdrasil.service" ];
    serviceConfig.Type = "oneshot";
    # copied from nixos/modules/services/networking/yggdrasil.nix
    script = let
      keysPath = "/var/lib/yggdrasil/keys.json";
      binYggdrasil = config.services.yggdrasil.package + "/bin/yggdrasil";
    in ''
      if [ ! -e ${keysPath} ]
      then
        mkdir --mode=700 -p ${builtins.dirOf keysPath}
        ${binYggdrasil} -genconf -json \
          | ${pkgs.jq}/bin/jq \
              'to_entries|map(select(.key|endswith("Key")))|from_entries' \
          > ${keysPath}
      fi
    '';
  };

  installScript = builtins.readFile ./install.sh;
}
