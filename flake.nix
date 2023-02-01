{
  description = "Services flake";

  outputs = { self, nixpkgs }:
    let
      services = [ "configs" "firewall" "nix-gc" "wireguard" "yggdrasil" ];
      supportedSystems = [ "x86_64-linux" ];
      lib = nixpkgs.lib;
      forAllSystems = lib.genAttrs supportedSystems;
      forAllServices = lib.genAttrs services;
      # does there not exist a concat-map for attribute sets?
      forAllServicesFlat = f:
        builtins.foldl' (l: r: l // r) { } (builtins.map f services);
    in {

      apps = forAllSystems (system:
        forAllServices (name: {
          type = "app";
          program = "${self.packages.${system}."app-${name}"}/bin/${name}";
        }));

      devShells =
        forAllSystems (system: { default = self.packages.${system}.devShell; });

      formatter = forAllSystems (system: self.packages.${system}.formatter);

      nixosModules = forAllServices (name: import "${self}/${name}") // {
        system = import "${self}/system.nix";
      };

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          selfpkgs = self.packages.${system};
        in (forAllServicesFlat (name:
          let
            configuration = {
              imports = [ self.nixosModules.system self.nixosModules.${name} ];
            };
            nixos = import "${nixpkgs}/nixos" { inherit configuration system; };
          in {

            "app-${name}" = pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = [ pkgs.nix ];
              text = ''
                name=${name}
                derivation=${selfpkgs."system-${name}"}
              '' + (builtins.readFile "${self}/profile.sh");
            };

            # TODO bleh
            # TODO map systems to debian archs?
            "package-${name}" = pkgs.runCommand "package-${name}" {
              installer =
                pkgs.writeShellScript "installer" nixos.config.installScript;
            } ''
              mkdir service-${name}
              export profile=/nix/var/nix/profiles/per-user/root/${name} install_to=service-${name}
              "$installer"
              mkdir service-${name}/DEBIAN
              cat >service-${name}/DEBIAN/control <<EOF
              Architecture: all
              Description: service-${name}
              Maintainer: Erry <astrosnail@protonmail.com>
              Package: service-${name}
              Version: 0.1.0-1
              EOF
              ${pkgs.dpkg}/bin/dpkg-deb --root-owner-group --build service-${name}
              mkdir "$out"
              mv service-${name}.deb "$out"
            '';

            "system-${name}" = nixos.system;

          })) // {

            devShell = pkgs.mkShell { buildInputs = [ pkgs.shellcheck ]; };

            formatter = pkgs.writeShellApplication {
              name = "formatter";
              runtimeInputs = [ pkgs.fd pkgs.nixfmt ];
              text = "fd --type=file --extension=nix --exec-batch nixfmt --";
            };

          });

    };
}
