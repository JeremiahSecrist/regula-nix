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
      nixosModules = rec {
        default = regula;
        regula = import ./modules/regula;
      };
      # checks = forAllSystems (system: let pkgs = pkgs' "${system}"; in {
      #   default = import ./tests {inherit self pkgs;};
      # });
    };
}
