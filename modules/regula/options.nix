# lib/options.nix -- Helper functions for defining options
{ lib, ... }:
let inherit (lib) mkEnableOption mkOption types;
in {
  regula = {
    # Enable option for the regula module
    enable = mkEnableOption "This enables the regula module";

    # Organizations configuration, allowing detailed nested options
    organizations = mkOption {
      type = with types;
        attrsOf (submodule {
          options = {
            description = mkOption {
              type = with types; str;
              description = ''
                used to explain the resource from which this rule set arrived.
              '';
            };
            homePage = mkOption {
              type = with types; str;
              description = ''
                A url to the organization involved
              '';
            };
          };
        });
    };

    # Rules configuration with enforcement modes and script placeholders
    rules = mkOption {
      type = with types;
        attrsOf (submodule {
          options = {
            enable = mkEnableOption "";
            mode = mkOption {
              type = enum [ "warning" "assertion" "buildValidation" ];
              default = "warning";
              description = ''
                Sets the mode for each rule.
                These modes are known as levels of enforcement:
                disabled
                warning
                assertion
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

            buildValidation = mkOption {
              type = attrs;
              description = ''
                A build package using runlocalCommand which validated a givin file.
                usage: { name=" "; nativeBuildInputs = []; script = ''''; file = pkgs.example.out; }
              '';
            };

            message = mkOption {
              type = lines;
              description = ''
                Describe your check in terms of generic security improvements.
              '';
            };

            verboseMessage = mkOption {
              type = lines;
              description = ''
                Describe your check in terms of generic security improvements.
              '';
              default = "";
            };
            # script = mkOption {
            #   type = lines;
            #   description = ''
            #     Idempotent runtime script written in Python.
            #     This script portion does not exist yet.
            #   '';
            # };
          };
        });
    };
  };
}
