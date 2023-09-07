{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.regula;
  mkAssertions = listOfProfiles: (
    lib.unique # remove duplicate assertions
    (
      builtins.filter (x: x.mode == 2) # mode 2 meants assert TODO: make warn system
      (
        lib.flatten # gets rid of nested lists
        listOfProfiles # should point to enabledProfiles
      )
    )
  );
in {
  # imports = [
  # ./standards/cis list: map (x: ${x}.rules ) list
  # ];
  options = import ./options.nix {inherit lib;};

  config = mkIf cfg.enable {
    assertions = mkAssertions config.regula.settings.enabledProfiles;
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
