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
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in {
      nixosModules = rec {
        default = regula;
        regula = import ./modules/regula;
      };
      checks.x86_64-linux.default = import ./tests {inherit self pkgs;};
    };
}
