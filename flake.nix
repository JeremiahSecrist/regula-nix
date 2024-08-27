{
  description = "regula-nix enforcing security standards on nixos";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
        docs = pkgs.callPackage ./packages/docs.nix { };
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
      checks.x86_64-linux.default = self.nixosConfigurations.default.config.system.build.toplevel;
    };
}
