{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption types mapAttrsToList;
  cfg = config.regula;
  rlib = import ./lib.nix { inherit lib; };
in
{
  options = import ./options.nix { inherit lib; };
  config = mkIf cfg.enable {
    warnings = rlib.failedAssertions (rlib.regulaToAssertion config.regula.rules "warning");
    assertions = (rlib.regulaToAssertion config.regula.rules "assertion");
    regula.rules = {
      bananana = {
        enable = true;
        assertion = (!true);
        mode = "assertion";
        message = "hello this is a bananana";
        verboseMessage = "verbose message hi";
      };
      taco = {
        enable = true;
        assertion = false;
        mode = "assertion";
        message = "hello this is a taco";
        verboseMessage = "verbose message taco";
      };
    };
  };
}
