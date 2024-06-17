# lib/options.nix -- Helper functions for defining options
{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in
  with types; {
    regula = {
      # Enable option for the regula module
      enable = mkEnableOption "This enables the regula module";
      
      settings = {
        # List of enabled profiles, allowing complex nested structures
        enabledProfiles = mkOption {
          type = listOf (listOf attrs);
        };
      };
      
      # Organizations configuration, allowing detailed nested options
      organizations = mkOption {
        type = attrsOf (submodule {
          options = {
            description = mkOption {
              type = str;
              description = ''
                used to explain the resource from which this rule set arrived.
              '';
            };
            homePage = mkOption {
              type = str;
              description = ''
                A url to the organization involved
              '';
            };
            assertMessage = mkOption {
              type = str;
            };
            profiles = mkOption {
              type = attrsOf (submodule {
                options = {
                  description = mkOption {
                    type = str;
                    description = ''
                      extra info about this specific profile.
                    '';
                  };
                  assertMessage = mkOption {
                    type = str;
                  };
                  rules = mkOption {
                    type = listOf attrs;
                  };
                  disabledRules = mkOption {
                    type = listOf (listOf attrs);
                  };
                };
              });
            };
          };
        });
      };
      
      # Rules configuration with enforcement modes and script placeholders
      rules = mkOption {
        type = attrsOf (submodule {
          options = {
            mode = mkOption {
              type = enum [0 1 2 3];
              default = 2;
              description = ''
                Sets the mode for each rule.
                These modes are known as levels of enforcement:
                0 = disabled
                1 = warning only
                2 = enforced (assertion)
                3 = strictly enforced (assertion + runtime)
              '';
            };
            assertion = mkOption {
              type = bool;
              default = false;
              description = ''
                Identical to NixOS modules assertion section.
                Declared here to improve other information around it.
              '';
            };
            genericMessage = mkOption {
              type = str;
              description = ''
                Describe your check in terms of generic security improvements.
              '';
            };
            script = mkOption {
              type = lines;
              description = ''
                Idempotent runtime script written in Python.
                This script portion does not exist yet.
              '';
            };
          };
        });
      };
    };
  }
