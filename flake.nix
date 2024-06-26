{
  description = "regula-nix enforcing security standards on nixos";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = inputs:
    with inputs; let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          # "aarch64-linux"
        ] (system: function nixpkgs.legacyPackages.${system});
    in {
      packages = forAllSystems (pkgs: {
        docs = pkgs.callPackage ./packages/docs.nix {};
      });
      apps = forAllSystems (pkgs: {
        serve = { type = "app"; program =  toString (pkgs.writeScript "doc-serve" ''
            ${pkgs.mdbook}/bin/mdbook serve ./docs/
          ''); };
      });
      nixosModules = rec {
        default = regula;
        regula = import ./modules/regula;
      };
      checks = forAllSystems (pkgs: {
        default = pkgs.callPackage ./tests {inherit self pkgs;};
      });
    };
}
