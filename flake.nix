{
  description = "Services flake";

  outputs = { self, nixpkgs }:
    let
      services = [
        "configs"
        "firewall"
        "nix-gc"
        "ubuntu-advantage-tools-stub"
        "wireguard"
        "yggdrasil"
      ];
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

            "control-${name}" =
              pkgs.writeText "control-${name}" nixos.config.debianControl;
            "install-${name}" = pkgs.writeShellApplication {
              inherit name;
              text = nixos.config.installScript;
            };

            "packager-${name}" = pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = [ pkgs.dpkg ];
              text = ''
                name=${name}
                control=${selfpkgs."control-${name}"}
                install=${selfpkgs."install-${name}"}/bin/${name}
              '' + (builtins.readFile "${self}/packager.sh");
            };

            "package-${name}" = pkgs.runCommand "package-${name}" { } ''
              ${selfpkgs."packager-${name}"}/bin/${name}
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
