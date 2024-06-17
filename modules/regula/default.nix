{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.regula;
  rlib = import ./lib.nix {inherit lib pkgs;};
in {
  options = import ./options.nix {inherit lib;};

  config = mkIf cfg.enable {
    assertions = rlib.mkAssertions config.regula.settings.enabledProfiles;
    warning = rlib.mkWarns config.regula.settings.enabledProfiles;
    regula = {
      settings.enabledProfiles = [
        config.regula.organizations.test.profiles.test.rules
        config.regula.organizations.test.profiles.test.rules
      ];
      organizations = {
        test = {
          profiles = {
            test = {
              rules = [
                config.regula.rules.demo
                config.regula.rules.demo2
              ];
            };
          };
        };
      };
      rules = {
        demo = {
          assertion = false;
          message = "hello";
          script = ''
          '';
        };
        demo2 = {
          assertion = false;
          message = "hello2";
          script = ''
          '';
        };
      };
    };
  };
}
