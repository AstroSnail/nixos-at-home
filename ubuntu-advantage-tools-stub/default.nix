{ config, ... }: {
  debianControl = ''
    Architecture: all
    Description: ubuntu-advantage-tools-stub
    Maintainer: Erry <${config.email}>
    Package: ubuntu-advantage-tools-stub
    Version: 0.1.0-1
    Provides: ubuntu-advantage-tools
    Conflicts: ubuntu-advantage-tools
    Replaces: ubuntu-advantage-tools
  '';
}
