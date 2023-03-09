{ lib, ... }:

{
  environment.etc = {

    "apt/apt.conf.d/11periodic-edit".text = ''
      APT::Periodic::MaxSize "2048";
      APT::Periodic::Download-Upgradeable-Packages "always";
      APT::Periodic::AutocleanInterval "always";
    '';

    "apt/apt.conf.d/21auto-upgrades-edit".text = ''
      APT::Periodic::Update-Package-Lists "always";
      APT::Periodic::Unattended-Upgrade "always";
    '';

    "default/motd-news".text = ''
      ENABLED=0
    '';

    "netplan/51-ipv6.yaml".text = ''
      network:
          version: 2
          ethernets:
              ens3:
                  dhcp6: false
                  match:
                      macaddress: fa:16:3e:1f:10:ff
                  addresses:
                      - "2001:41d0:304:200::4150/128"
                  gateway6: "2001:41d0:304:200::1"
                  routes:
                      - to: "2001:41d0:304:200::1"
                        scope: "link"
                      - to: "::/0"
                        via: "2001:41d0:304:200::1"
    '';

    "ssh/sshd_config.d/00-my.conf".text = ''
      AllowUsers ubuntu
      # Reduce logspam
      LogLevel ERROR
      PasswordAuthentication no
      PermitRootLogin no
      X11Forwarding no
    '';

    "systemd/journald.conf.d/00-system-max-use.conf".text = ''
      [Journal]
      SystemMaxUse=2G
    '';

  };

  debianControl = ''
    Architecture: all
    Description: service-configs
    Maintainer: Erry <astrosnail@protonmail.com>
    Package: service-configs
    Version: 0.1.0-1
    Provides: motd-news-config
    Conflicts: motd-news-config
    Replaces: motd-news-config
  '';

  installScript = lib.readFile ./install.sh;
}
