{ lib, ... }:

let
  # this is a very cheap config-generator
  # properly made, it should be a module with options
  value-to-conf = value:
    {
      bool = if value then "yes" else "no";
      list = lib.concatMapStringsSep "," value-to-conf value;
    }.${builtins.typeOf value} or (builtins.toString value);
  gen-line = name: value: ''
    ${name}=${value-to-conf value}
  '';
  gen-config = conf: lib.concatStrings (lib.mapAttrsToList gen-line conf);

in { lib.pdns = { inherit gen-config; }; }
