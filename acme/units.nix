{
  config,
  lib,
  pkgs,
  ...
}:

{
  systemd.services =
    let
      account-configs = config.lib.acme.account-configs config.security.acme.certs;
      dependantService =
        hash: cert:
        lib.nameValuePair "acme-${cert}" {
          requires = [ "acme-account-${hash}.target" ];
        };
      dependantServices = hash: certs: lib.lists.map (dependantService hash) (lib.tail certs);
      allServices = lib.concatLists (lib.mapAttrsToList dependantServices account-configs);
    in
    lib.listToAttrs allServices;
}
