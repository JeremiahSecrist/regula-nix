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

    regula.rules = {
      bananana = {
        enable = true;
        # assertion = (!config.programs.tmux.enable);
        mode = "buildValidation";
        buildValidation = { name = "hi"; script = "touch $out"; };
        message = "tmux is not a nana";
        verboseMessage = "verbose message hi";
      };
      taco = {
        # enable = true;
        assertion = false;
        mode = "assertion";
        message = "hello this is a taco";
        verboseMessage = "verbose message taco";
      };
    };
  };
}
