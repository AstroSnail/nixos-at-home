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

    "ssh/sshd_config.d/my.conf".text = ''
      AllowUsers ubuntu
      # Reduce logspam
      LogLevel ERROR
      PasswordAuthentication no
      PermitRootLogin no
      X11Forwarding no
    '';

    "systemd/journald.conf.d/system-max-use.conf".text = ''
      [Journal]
      SystemMaxUse=2G
    '';

  };

  installScript = builtins.readFile ./install.sh;
}
