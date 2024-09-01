{
  description = "regula-nix enforcing security standards on nixos";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixdoc = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:adisbladis/mdbook-nixdoc";
    };
  };
  outputs =
    inputs:
    with inputs;
    let
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          # "aarch64-linux"
        ] (system: function nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default = self.nixosConfigurations.default.config.system.build.toplevel;
        docs = pkgs.callPackage ./packages/docs.nix {
          mdbook-nixdoc = nixdoc.packages.x86_64-linux.default;
        };
      });
      apps = forAllSystems (pkgs: {
        serve = {
          type = "app";
          program = toString (
            pkgs.writeScript "doc-serve" ''
              ${pkgs.mdbook}/bin/mdbook serve ./docs/
            ''
          );
        };
        act = {
          type = "app";
          program = toString (
            pkgs.writeScript "doc-serve" ''
              ${pkgs.act}/bin/act
            ''
          );
        };
        statix = {
          type = "app";
          program = toString (
            pkgs.writeScript "statix" ''
              ${pkgs.statix}/bin/statix $@
            ''
          );
        };
      });
      # Sample config to test behaviors
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.regula
          ./packages/test-system.nix
        ];
      };
      nixosModules = {
        default = self.nixosModules.regula;
        regula = import ./modules/regula;
      };
      checks = forAllSystems (pkgs: {
        default = self.nixosConfigurations.default.config.system.build.toplevel;
        codeCheck = pkgs.callPackage (
          {
            runCommandNoCCLocal,
            statix,
            deadnix,
            nixfmt-rfc-style,
          }:
          runCommandNoCCLocal "statix-check"
            {
              buildInputs = [
                statix
                deadnix
                nixfmt-rfc-style
              ];
            }
            ''
              touch $out
              statix check ${self}  | tee -a $out
              deadnix check --fail ${self} | tee -a $out
              nixfmt -c ${self} | tee -a $out
            ''
        ) { };
      });
    };
}
