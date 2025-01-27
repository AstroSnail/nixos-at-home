{
  description = "Services flake";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11"; };

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
      hostSystems = {
        x86_64-linux = [ "sea" "sea2" ];
        aarch64-linux = [ "sunrise" ];
      };

      lib = nixpkgs.lib;
      supportedSystems = lib.attrNames hostSystems;
      flakeOutputs = f:
        let
          f-with-system = system:
            lib.mapAttrsToList (name: value:
              lib.nameValuePair name (lib.nameValuePair system value))
            (f system);
          f-all-systems = lib.concatMap f-with-system supportedSystems;
          combined-outputs = lib.groupBy (x: x.name) f-all-systems;
          combine-systems = output-systems:
            lib.listToAttrs (lib.lists.map (x: x.value) output-systems);
        in lib.mapAttrs (name: combine-systems) combined-outputs;

      concatGenAttrs = names: f:
        lib.listToAttrs
        (lib.concatMap (n: lib.mapAttrsToList lib.nameValuePair (f n)) names);
      forAllServices = lib.genAttrs services;
      forAllServicesFlat = concatGenAttrs services;

      parse-flake = src:
        let
          flake = builtins.import (src + "/flake.nix");
          outputs = flake.outputs { self = outputs; };
        in outputs;

      nixosModules = forAllServices
        (name: { imports = [ "${self}/main.nix" "${self}/${name}" ]; });

      nixosConfigurations = forAllServicesFlat (name: let in { });

    in flakeOutputs (system:
      let
        host = "sea";

        pkgs = nixpkgs.legacyPackages.${system};

        app-script = pkgs.writeShellApplication {
          name = "app-script";
          runtimeInputs = [ pkgs.nix ];
          text = lib.readFile "${self}/profile.sh";
        };

        apps = forAllServices (name:
          let
            app = pkgs.stdenv.mkDerivation {
              name = "app-${name}";
              nativeBuildInputs = [ pkgs.makeWrapper ];
              phases = [ "installPhase" ];
              installPhase = ''
                makeWrapper ${app-script}/bin/app-script $out \
                  --set self ${self} \
                  --set name ${name}
              '';
            };

          in {
            type = "app";
            program = builtins.toString app;
          });

        devShell = pkgs.mkShell { buildInputs = [ pkgs.shellcheck ]; };

        formatter = pkgs.writeShellApplication {
          name = "formatter";
          runtimeInputs = [ pkgs.fd pkgs.nixfmt ];
          text = "fd --type=file --extension=nix --exec-batch nixfmt --";
        };

        packager-script = pkgs.writeShellApplication {
          name = "packager-script";
          runtimeInputs = [ pkgs.dpkg ];
          text = lib.readFile "${self}/packager.sh";
        };

        packages = forAllServicesFlat (name:
          let
            nixpkgs-patched =
              if lib.pathExists "${self}/${name}/nixpkgs.patch" then
                parse-flake (pkgs.applyPatches {
                  name = "nixpkgs-patched";
                  src = nixpkgs;
                  patches = [ "${self}/${name}/nixpkgs.patch" ];
                })
              else
                nixpkgs;

            modules = [ nixosModules.${name} { networking.hostName = host; } ];

            nixos = nixpkgs-patched.lib.nixosSystem { inherit modules system; };

            nixos-system = nixos.config.system.build.toplevel;

            control =
              pkgs.writeText "control-${name}" nixos.config.debianControl;

            install = pkgs.writeShellApplication {
              name = "install-script";
              text = nixos.config.installScript;
            };

            postinst = let script = nixos.config.postInstallScript;
            in if script != "" then
              pkgs.writeText "postinst-${name}" script
            else
              null;

            packager = pkgs.stdenv.mkDerivation {
              name = "packager-${name}";
              nativeBuildInputs = [ pkgs.makeWrapper ];
              phases = [ "installPhase" ];
              installPhase = ''
                makeWrapper ${packager-script}/bin/packager-script $out \
                  --set name ${name} \
                  --set control ${control} \
                  --set install ${install}/bin/install-script \
                  --set postinst '${builtins.toString postinst}'
              '';
            };

            package = pkgs.runCommand "package-${name}" { } ''
              ${packager}
            '';

          in {
            "package-${name}" = package;
            "system-${name}" = nixos-system;
          });

      in {
        inherit apps formatter packages;
        devShells.default = devShell;
      }) // {
        inherit nixosConfigurations nixosModules;
      };
}
