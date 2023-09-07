# lib/options.nix -- Helper functions for defining options
{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in
  with types; {
    regula = {
      enable = mkEnableOption "This enables the regula module";
      settings = {
        enabledProfiles = mkOption {
          type = listOf (listOf attrs);
        };
      };
      organizations = mkOption {
        type = attrsOf (submodule {
          options = {
            description = mkOption {
              type = string;
            };
            assertMessage = mkOption {
              type = string;
            };
            profiles = mkOption {
              type = attrsOf (submodule {
                options = {
                  description = mkOption {
                    type = string;
                  };
                  assertMessage = mkOption {
                    type = string;
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
      rules = mkOption {
        type = attrsOf (submodule {
          options = {
            mode = mkOption {
              type = enum [0 1 2];
              default = 2;
            };
            assertion = mkOption {
              type = bool;
              default = false;
            };
            message = mkOption {
              type = string;
            };
            script = mkOption {
              type = lines;
            };
          };
        });
      };
    };
  }
