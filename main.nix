{ config, lib, ... }:

{
  options = let
    t = lib.types;
    optionLines = lib.mkOption {
      type = t.lines;
      default = "";
    };
    optionStr = lib.mkOption {
      type = t.nullOr t.str;
      default = null;
    };
    host = { config, ... }: {
      options = {
        ipv4 = optionStr;
        ipv6 = optionStr;
        wg-addr = optionStr;
        wg-pub = optionStr;
        yggd-addr = optionStr;
        yggd-pub = optionStr;
        sshfp = optionStr;
        loc = optionStr;
      };
    };
    host-sub = t.submodule host;
  in {
    # for building the packages
    debianControl = optionLines;
    installScript = optionLines;
    postInstallScript = optionLines;

    # useful data
    email = optionStr;
    hosts = lib.mkOption { type = t.lazyAttrsOf host-sub; };
    this-host = lib.mkOption { type = host-sub; };
  };

  config = {
    # skip assertions about bootability
    boot.isContainer = lib.mkDefault true;

    # skip warning about state versions
    system.stateVersion = lib.mkDefault config.system.nixos.release;

    # "system-wide" config
    networking.hostName = "sea";
    networking.domain = "astrosnail.pt.eu.org";

    # TODO: separate and link in, as this is very generally useful
    email = "astrosnail@protonmail.com";

    # retired
    #hosts.snail.ipv4 = "94.60.30.250";
    #hosts.snail.ipv6 = "2001:818:df73:f400:c0ff:eeba:d7ea:900d";
    #hosts.snail.wg-addr = "fd57:337f:9040:1:1:1:1:1";
    #hosts.snail.wg-pub = "Rc7Ft6ljK9pyRmrwzQmfsIEIpqsTpCu+1hlAaTfDyzc=";
    #hosts.snail.sshfp = "";

    hosts.soon.ipv4 = "94.60.30.250";
    hosts.soon.ipv6 = "2001:818:df73:f400::abba:cad:abba";
    hosts.soon.wg-addr = "fd57:337f:9040:1:2:3:4:5";
    hosts.soon.wg-pub = "Rc7Ft6ljK9pyRmrwzQmfsIEIpqsTpCu+1hlAaTfDyzc=";
    hosts.soon.yggd-addr = "200:677f:abc:380b:6c78:73b5:c72e:c1f3";
    hosts.soon.yggd-pub =
      "cc407aa1e3fa49c3c6251c689f066afac7e0f8b4cf5744e0cd18446cf32fe51f";
    # Portugal (centered at the Picoto da Melriça)
    hosts.soon.loc = "39 41 40 N 8 7 50 W 592m 10m 600000m 2000m";
    hosts.soon.sshfp =
      "4 2 e3cde17417165ec78a4f26f2438ce43b142d9d87ef594e73171269b01d1a8632";

    hosts.sea.ipv4 = "146.59.231.219";
    hosts.sea.ipv6 = "2001:41d0:304:200::4150";
    hosts.sea.wg-addr = "fd57:337f:9040:1::5ea";
    hosts.sea.wg-pub = "vSL3Pqd1oIDwWFmwCtWBAhjBYf5de2mx5+EVpYk8uDs=";
    hosts.sea.yggd-addr = "207:f201:452c:4b9b:64a7:8afe:4620:1ede";
    hosts.sea.yggd-pub =
      "010dfebad3b4649b587501b9dfe1219411bfb413d5a3cd499be2fe1aa64676f3";
    # OVHcloud Gravelines
    hosts.sea.loc = "51 1 N 2 9 E 0m 500m 2000m 100m";
    hosts.sea.sshfp =
      "4 2 8541fb35fc4db160d2836bf49f5e239c9f5869037c4851777f72d51704e5655f";

    #hosts.smol.wg-addr = "fd57:337f:9040:1:1:1:1:2";
    #hosts.smol.wg-pub = "Lp5hmSdapd8LPYpdLb2+8eBKq3mV6PO7gi2VIVv3d2s=";
    hosts.smol.yggd-addr = "204:3e20:38b0:d4fc:c1db:8a4c:cf17:424d";
    hosts.smol.yggd-pub =
      "0e0efe3a795819f123ad998745ed92b28b909eff789546e720617c5ca6039f95";
    #hosts.smol.sshfp = "";

    # retired
    #hosts.sonar.wg-addr = "fd57:337f:9040:1:9ca7:9ca7:9ca7:9ca7";
    #hosts.sonar.wg-pub = "spQBkQX/+mB1MmVvDnjs1IEHInDKOxPMjhgs0OyJCi8=";
    #hosts.sonar.yggd-addr = "202:2d0d:edc4:38af:ccb9:efb6:59de:421d";
    #hosts.sonar.yggd-pub =
    #  "3a5e424778ea0668c20934c437bc5a4461bee610fbc60821c363558b1fbb0fed";

    hosts.soon-prime.wg-addr = "fd57:337f:9040:1:5:4:3:2";
    hosts.soon-prime.wg-pub = "q9Pmyalgp+Qt2NU3ewng0WW7lfFIjEEMExWqHg5CVV0=";
    hosts.soon-prime.yggd-addr = "200:2ab6:23c:e13c:5902:4bbc:4afe:509c";
    hosts.soon-prime.yggd-pub =
      "eaa4fee18f61d37eda21da80d7b199cd1478dbb5a4cf1d45869b5189bbb83896";
    hosts.soon-prime.sshfp =
      "4 2 17e13bf0ed8a0d7a9f492c4d5cd5825d3cee65d5747e7b2bd7580057faec48c0";

    #hosts.shinx.wg-addr = "";
    #hosts.shinx.wg-pub = "";
    hosts.shinx.yggd-addr = "200:2853:f73e:b83a:4275:16bf:208:abe4";
    hosts.shinx.yggd-pub =
      "ebd60460a3e2dec574a07efbaa0db3d640e8c80da7321dcd2585b2ad6d1571e9";

    hosts.sunrise.ipv4 = "162.55.184.64";
    hosts.sunrise.ipv6 = "2a01:4f8:c0c:1013::1";
    #hosts.sunrise.wg-addr = "";
    #hosts.sunrise.wg-pub = "";
    #hosts.sunrise.yggd-addr = "";
    #hosts.sunrise.yggd-pub = "";
    # Hetzner Nürnberg
    hosts.sunrise.loc = "49 27 N 11 1 E 300m 500m 2000m 100m";
    hosts.sunrise.sshfp =
      "4 2 9ae2cb1a3c3276dce2aba204bc0db398a0a01c75a253af174bfa74c5d4bfafd1";

    hosts.sea2.ipv4 = "149.56.12.16";
    hosts.sea2.ipv6 = "2607:5300:201:3100::85d2";
    #hosts.sea2.wg-addr = "";
    #hosts.sea2.wg-pub = "";
    #hosts.sea2.yggd-addr = "";
    #hosts.sea2.yggd-pub = "";
    # OVHcloud Beauharnois
    hosts.sea2.loc = "45 19 N 73 54 W 0m 500m 2000m 100m";
    hosts.sea2.sshfp =
      "4 2 f8a66351be3c68ff22da9dd23136e8979ef6da4a0c731276abc9b2ff8f0bed61";

    this-host = config.hosts.${config.networking.hostName};
  };

}
