{
  description = "Services flake";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; };

  outputs = { self, nixpkgs }:
    let
      services = [
        "acme"
        "configs"
        "dnsdist"
        "firewall"
        "nginx"
        "nix-gc"
        "powerdns"
        "tor"
        "ubuntu-advantage-tools-stub"
        "wireguard"
        "yggdrasil"
      ];
      supportedSystems = [ "x86_64-linux" ];

      lib = nixpkgs.lib;
      forAllSystems = lib.genAttrs supportedSystems;
      forAllServices = lib.genAttrs services;
      forAllServicesFlat = f: lib.listToAttrs (lib.concatMap f services);

      parse-flake = flakeSrc:
        let
          flake = builtins.import (flakeSrc + "/flake.nix");
          outputs = flake.outputs { self = outputs; };
        in outputs;

    in {

      apps = forAllSystems (system:
        forAllServices (name: {
          type = "app";
          program = "${self.packages.${system}."app-${name}"}/bin/${name}";
        }));

      devShells =
        forAllSystems (system: { default = self.packages.${system}.devShell; });

      formatter = forAllSystems (system: self.packages.${system}.formatter);

      nixosModules = forAllServices
        (name: { imports = [ "${self}/main.nix" "${self}/${name}" ]; });

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          devShell = pkgs.mkShell { buildInputs = [ pkgs.shellcheck ]; };

          formatter = pkgs.writeShellApplication {
            name = "formatter";
            runtimeInputs = [ pkgs.fd pkgs.nixfmt ];
            text = "fd --type=file --extension=nix --exec-batch nixfmt --";
          };

        in (forAllServicesFlat (name:
          let
            nixpkgs-patched = if lib.pathExists ./${name}/nixpkgs.patch then
              parse-flake (pkgs.applyPatches {
                name = "nixpkgs-patched";
                src = nixpkgs;
                patches = [ ./${name}/nixpkgs.patch ];
              })
            else
              nixpkgs;

            modules = [ self.nixosModules.${name} ];

            nixos = nixpkgs-patched.lib.nixosSystem { inherit modules system; };

            app = pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = [ pkgs.nix ];
              text = ''
                self=${self}
                name=${name}
              '' + (lib.readFile "${self}/profile.sh");
            };

            control =
              pkgs.writeText "control-${name}" nixos.config.debianControl;

            install = pkgs.writeShellApplication {
              inherit name;
              text = nixos.config.installScript;
            };

            packager = pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = [ pkgs.dpkg ];
              text = ''
                name=${name}
                control=${control}
                install=${install}/bin/${name}
              '' + (lib.readFile "${self}/packager.sh");
            };

            package = pkgs.runCommand "package-${name}" { } ''
              ${packager}/bin/${name}
            '';

            nixos-system = nixos.config.system.build.toplevel;

          in [
            (lib.nameValuePair "app-${name}" app)
            (lib.nameValuePair "control-${name}" control)
            (lib.nameValuePair "install-${name}" install)
            (lib.nameValuePair "packager-${name}" packager)
            (lib.nameValuePair "package-${name}" package)
            (lib.nameValuePair "system-${name}" nixos-system)
          ])) // {
            inherit devShell formatter;
          });

    };
}
