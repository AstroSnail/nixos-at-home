{ config, lib, ... }:

let t = lib.types;

in {
  # skip assertions about bootability
  config.boot.isContainer = lib.mkDefault true;

  # skip warning about state versions
  config.system.stateVersion = lib.mkDefault config.system.nixos.release;

  # for building the packages
  options.debianControl = lib.mkOption { type = t.str; };
  options.installScript = lib.mkOption { type = t.str; };

  # "system-wide" config
  config.networking.hostName = "sea";
  config.networking.domain = "astrosnail.pt.eu.org";

  # useful data
  options.ips = lib.mkOption { type = t.lazyAttrsOf t.str; };
  config.ips = {
    #snail-ipv4 = "94.60.30.250";
    snail-ipv6 = "2001:818:df73:f400:c0ff:eeba:d7ea:900d";
    #snail-yggd = "";
    #snail-wg = "";

    soon-ipv4 = "94.60.30.250";
    soon-ipv6 = "2001:818:df73:f400:0:abba:cad:abba";
    soon-yggd = "200:677f:abc:380b:6c78:73b5:c72e:c1f3";
    soon-wg = "fd57:337f:9040:1:2:3:4:5";

    sea-ipv4 = "146.59.231.219";
    sea-ipv6 = "2001:41d0:304:200::4150";
    sea-yggd = "207:f201:452c:4b9b:64a7:8afe:4620:1ede";
    sea-wg = "fd57:337f:9040:1::5ea";

    #smol-ipv4 = "";
    #smol-ipv6 = "";
    #smol-yggd = "";
    smol-wg = "fd57:337f:9040:1:1:1:1:2";

    #sonar-ipv4 = "";
    #sonar-ipv6 = "";
    sonar-yggd = "202:2d0d:edc4:38af:ccb9:efb6:59de:421d";
    sonar-wg = "fd57:337f:9040:1:9ca7:9ca7:9ca7:9ca7";

    #soon-prime-ipv4 = "";
    #soon-prime-ipv6 = "";
    soon-prime-yggd = "200:2ab6:23c:e13c:5902:4bbc:4afe:509c";
    soon-prime-wg = "fd57:337f:9040:1:5:4:3:2";
  };
}
