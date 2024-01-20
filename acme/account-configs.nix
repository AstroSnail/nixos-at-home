{ lib, ... }:

let
  # generally simplified copy of functions in the nixos module

  mkHash = val: lib.substring 0 20 (builtins.hashString "sha256" val);
  mkAccountHash = data:
    mkHash "${builtins.toString data.server} ${data.keyType} ${data.email}";

  certToConfig = cert: data: {
    inherit cert;
    accountHash = mkAccountHash data;
  };
  certConfigs = lib.mapAttrsToList certToConfig;
  account-configs = certs:
    lib.groupBy' (certs: conf: certs ++ [ conf.cert ]) [ ]
    (conf: conf.accountHash) (certConfigs certs);

in { lib.acme = { inherit account-configs; }; }
