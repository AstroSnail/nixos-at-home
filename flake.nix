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
      hostSystems = {
        x86_64-linux = [ "sea" "sea2" ];
        aarch64-linux = [ "sunrise" ];
      };

      lib = nixpkgs.lib;
      supportedSystems = lib.attrNames hostSystems;
      forAllSystems = lib.genAttrs supportedSystems;
      forAllServices = lib.genAttrs services;
      forAllServicesFlat = f: lib.listToAttrs (lib.concatMap f services);

      parse-flake = flakeSrc:
        let
          flake = builtins.import (flakeSrc + "/flake.nix");
          outputs = flake.outputs { self = outputs; };
        in outputs;

      make-nixos = { pkgs, system, host, name }:
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

          modules =
            [ self.nixosModules.${name} { networking.hostName = host; } ];

          nixos = nixpkgs-patched.lib.nixosSystem { inherit modules system; };

        in nixos;

    in {

      apps = forAllSystems (system:
        forAllServices (name: {
          type = "app";
          program = builtins.toString self.packages.${system}."app-${name}";
        }));

      devShells =
        forAllSystems (system: { default = self.packages.${system}.devShell; });

      formatter = forAllSystems (system: self.packages.${system}.formatter);

      nixosModules = forAllServices
        (name: { imports = [ "${self}/main.nix" "${self}/${name}" ]; });

      nixosConfigurations = forAllServicesFlat (name:
        let
        in [
          #(lib.nameValuePair "app-${name}" app)
        ]);

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
            nixos = make-nixos {
              inherit pkgs system name;
              host = "sea";
            };

            app-script = pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = [ pkgs.nix ];
              text = lib.readFile "${self}/profile.sh";
            };

            app = pkgs.stdenv.mkDerivation {
              name = "app-${name}";
              nativeBuildInputs = [ pkgs.makeWrapper ];
              phases = [ "installPhase" ];
              installPhase = ''
                makeWrapper ${app-script}/bin/${name} $out \
                  --set self ${self} \
                  --set name ${name}
              '';
            };

            control =
              pkgs.writeText "control-${name}" nixos.config.debianControl;

            install = pkgs.writeShellApplication {
              inherit name;
              text = nixos.config.installScript;
            };

            postinst = let script = nixos.config.postInstallScript;
            in if script != "" then
              pkgs.writeText "postinst-${name}" script
            else
              null;

            packager-script = pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = [ pkgs.dpkg ];
              text = lib.readFile "${self}/packager.sh";
            };

            packager = pkgs.stdenv.mkDerivation {
              name = "packager-${name}";
              nativeBuildInputs = [ pkgs.makeWrapper ];
              phases = [ "installPhase" ];
              installPhase = ''
                makeWrapper ${packager-script}/bin/${name} $out \
                  --set name ${name} \
                  --set control ${control} \
                  --set install ${install}/bin/${name} \
                  --set postinst '${builtins.toString postinst}'
              '';
            };

            package = pkgs.runCommand "package-${name}" { } ''
              ${packager}
            '';

            nixos-system = nixos.config.system.build.toplevel;

          in [
            (lib.nameValuePair "app-${name}" app)
            (lib.nameValuePair "package-${name}" package)
            (lib.nameValuePair "system-${name}" nixos-system)
          ])) // {
            inherit devShell formatter;
          });

    };
}
