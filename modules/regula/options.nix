# lib/options.nix -- Helper functions for defining options
{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
in
{
  regula = {
    # Enable option for the regula module
    enable = mkEnableOption "This enables the regula module";
    # by default we don't enable anything because not all projects should be expected to use all features
    buildValidation = {
      vmTest.enable = mkEnableOption "Creates a vm with the host config to run tests";
      system.enable = mkEnableOption "enables checks at the toplevel of the nixos system derivation";
      perPackage.enable = mkEnableOption "enables perPackage scripts that accept explicit packages / configs to run checks on";
    };
    assertions.enable = mkEnableOption "enables eval time assertions";
    warnings.enable = mkEnableOption "enables eval time warnings";
    # Organizations configuration, allowing detailed nested options
    organizations = mkOption {
      type =
        with types;
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
      default = null;
      type =
        with types;
        nullOr (
          attrsOf (submodule {
            options = {
              enable = mkEnableOption "";
              mode = mkOption {
                type = enum [
                  "warning"
                  "assertion"
                  "buildValidation"
                  "toplevelBuildValidation"
                  "nixosTest"
                ];
                default = "warning";
                description = ''
                  Sets the mode for each rule.
                  These modes are known as levels of enforcement:
                    disabled
                    warning
                    assertion
                    buildValidation
                    toplevelValidation
                    nixosTest
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
              meta = {
                maintainers = mkOption {
                  type = listOf raw;
                  description = "This options is for knowledge of maintainers and is not evaluated";
                };
                declared = mkOption {
                  type = str;
                  description = "Marks the location of the file that this rule is dlcared in";
                };
                discovery = mkOption {
                  type = with types; listOf (attrsOf str);
                  description = "Used during eval time and is displayed each item as a newline, also provides the ability to filter via nix in the future";
                };
              };
              buildValidation = mkOption {
                type = nullOr attrs;
                default = null;
                description = ''
                  Please use a runlocalCommand
                '';
              };
              toplevelBuildValidation = mkOption {
                type = nullOr package;
                default = null;
                description = ''
                  This is passed into the toplevel of the nixos build stages.
                  Use a derivation via runlocalCommand and keep the check short.
                '';
              };
              vm = {
                testScript = mkOption {
                  type = nullOr lines;
                  default = null;
                  description = ''
                    Systemd service that is oneshot at startup and runs your script and checks for valid behavior.
                  '';
                };

                extraVmConfig = mkOption {
                  type = nullOr package;
                  default = null;
                  description = ''
                    Systemd service that is oneshot at startup and runs your script and checks for valid behavior.
                  '';
                };
              };
              message = mkOption {
                type = lines;
                description = ''
                  Describe your check in terms of generic security improvements.
                '';
              };
            };
          })
        );
    };
  };
}
