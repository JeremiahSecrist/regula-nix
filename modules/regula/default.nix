{
  config,
  lib,
  pkgs,
  ...
}: let
  # TODO: Make warn system
  # TODO: Incorperate various context message
  # TODO: Expand out regula.settings.enabledProfiles
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.regula;
  mkAssertions = listOfProfiles:
  (lib.unique # remove duplicate assertions
    ( builtins.filter (x: x.mode == 2) # mode 2 meants assert
      ( lib.flatten # gets rid of nested lists
        (map (f: map (f2: {inherit (f2) assertion mode; message = "${f.assertMessage} ${f2.message}";} ) f.rules ) # this mapping adds the profile metadata to the assertion
        listOfProfiles # should point to enabledProfiles
        ))));
in {
  options = import ./options.nix {inherit config lib;};
  config = mkIf cfg.enable {
    assertions = mkAssertions config.regula.settings.enabledProfiles;
    # TODO: Make wrapper to warnings
    # warnings = [
    #   mkProfileEnum
    # ];
    regula = {
      settings.enabledProfiles =[ # non-functional as of yet. but desired state
        "orgtest.test"
      ];
      organizations = {
        orgtest = {
          assertMessage = "org hello there:";
          profiles = rec {
            test2 = test;
            test = {
              assertMessage = "profile: test-v1:";
              rules = with config.regula.rules; [
                demo
                demo2
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
