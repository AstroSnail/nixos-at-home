{ lib, ... }:

let
  # this is a very cheap config-generator
  # properly made, it should be a module with options
  value-to-conf = value:
    {
      bool = if value then "yes" else "no";
      list = lib.concatMapStringsSep "," value-to-conf value;
    }.${builtins.typeOf value} or (builtins.toString value);
  gen-line = name: value: "${name}=${value-to-conf value}";
  gen-config = lib.flip lib.pipe [
    (lib.mapAttrs gen-line)
    lib.attrValues
    (lib.concatStringsSep "\n")
  ];

in { lib.pdns = { inherit gen-config; }; }
