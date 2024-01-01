{
  description = "Services flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

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
      # does there not exist a concat-map for attribute sets?
      # there exists lib.concatMapAttrs but i want to take a list, not attrset
      forAllServicesFlat = f:
        lib.foldl lib.trivial.mergeAttrs { } (builtins.map f services);
      parse-flake = flakeSrc:
        let
          flake = import (flakeSrc + "/flake.nix");
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

      nixosModules = forAllServices (name: import "${self}/${name}") // {
        main = import "${self}/main.nix";
      };

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          nixpkgs-patched = pkgs.applyPatches {
            name = "nixpkgs-patched";
            src = nixpkgs;
            patches = [ ./nixpkgs.patch ];
          };
          nixpkgs-patched-flake = parse-flake nixpkgs-patched;
        in let
          nixpkgs = nixpkgs-patched-flake;
          pkgs = nixpkgs.legacyPackages.${system};
          selfpkgs = self.packages.${system};
        in (forAllServicesFlat (name:
          let
            modules = [{
              imports = [ self.nixosModules.main self.nixosModules.${name} ];
            }];
            nixos = nixpkgs.lib.nixosSystem { inherit modules system; };
          in {

            "app-${name}" = pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = [ pkgs.nix ];
              text = ''
                name=${name}
                derivation=${selfpkgs."system-${name}"}
              '' + (lib.readFile "${self}/profile.sh");
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
              '' + (lib.readFile "${self}/packager.sh");
            };

            "package-${name}" = pkgs.runCommand "package-${name}" { } ''
              ${selfpkgs."packager-${name}"}/bin/${name}
            '';

            "system-${name}" = nixos.config.system.build.toplevel;

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
