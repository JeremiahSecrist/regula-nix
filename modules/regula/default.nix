{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption types mapAttrsToList;
  cfg = config.regula;
  rlib = import ./lib.nix { inherit lib pkgs; };
in
{
  options = import ./options.nix { inherit lib; };
  config = mkIf cfg.enable {
    warnings = rlib.failedAssertionsToListOfStr (rlib.regulaToAssertion config.regula.rules "warning");
    assertions = (rlib.regulaToAssertion config.regula.rules "assertion");
    system.checks = map (x: (rlib.checkFile x.buildValidation)) (builtins.filter (x: (x.mode == "buildValidation" && x.enable)) (mapAttrsToList (n: v: v) cfg.rules));
  };
}
