# lib/options.nix -- Helper functions for defining options
{
  # config,
  # options,
  # pkgs,
  rlib,
  lib,
  ...
}:
let
  # config' = config;
  inherit (lib) mkEnableOption mkOption replaceStrings;
  inherit (lib.types)
    submodule
    # functionTo
    package
    # enum
    listOf
    attrsOf
    attrs
    str
    lines
    raw
    bool
    ;

in
{
  regula = {
    # Enable option for the regula module
    enable = mkEnableOption "This enables the regula module";
    # by default we don't enable anything because not all projects should be expected to use all features
    features = {
      toplevel.enable = mkEnableOption "enables checks at the toplevel of the nixos system derivation";
      packageChecks.enable = mkEnableOption "enables perPackage scripts that accept explicit packages / configs to run checks on";
      assertions.enable = mkEnableOption "enables eval time assertions";
      warnings.enable = mkEnableOption "enables eval time warnings";
      nixosTesting.enable = mkEnableOption "Creates a vm with the host config to run tests";
    };
    # Organizations configuration, allowing detailed nested options
    # maybe this should just be attrsOf (attrs or str)
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
        };
      });
    };

    # Rules configuration with enforcement modes and script placeholders
    rules = mkOption {
      type = attrsOf (
        submodule (
          {
            # name,
            config,
            options,
            ...
          }:
          {
            options = {
              enable = mkEnableOption "" // {
                description = "by default all declared modules are assumed to be enabled as they should be gated";
                default = true;
              };

              # tests need to be built into one vm
              vm = {
                enable = mkEnableOption "" // {
                  description = "We only want this to be enabled if testScript is defined";
                  default = options.vm.testScript.isDefined;
                };
                isolated = mkOption {
                  type = bool;
                  default = false;
                  description = ''
                    Should you desire seperate vms for each test this can be accomodated
                    but is not recommended as build time could become exponential
                  '';
                };
                testScript = mkOption {
                  type = lines;
                  description = ''
                    RunNixOSTest scripts written in python.
                    It is ideal that the tests be isolated using `with subtest("@failureContext@"):`
                    in order to enable faster vm testing.
                    additonally @failureContext@ allows for a replacement with extra info provided in discovery.
                    Please see https://nixos.org/manual/nixpkgs/stable/#tester-runNixOSTest for more info.
                  '';
                };
                _testScriptCompiled = mkOption {
                  type = lines;
                  default = replaceStrings [ "@failureContext" ] [
                    (rlib.attrsToMessage config.meta.failureContext)
                  ] config.vm.testScript;
                };
                extraVmConfigs = mkOption {
                  type = listOf attrs;
                  description = ''
                    Allows the test to modify the vm configuration. This is important for situations where
                    the nixos configuration is expect physical hardware or other services to be active.
                  '';
                };
              };
              build = {
                toplevel = {
                  enable = mkEnableOption "" // {
                    description = "We only want this to be enabled if testScript is defined";
                    default = config.build.toplevel.package.isDefined;
                  };
                  package = mkOption {
                    type = package;
                    description = ''
                      This package should be designed to inspect the output of a nixos build file structure.
                    '';
                  };
                  _packageOverride = mkOption {
                    type = package;
                    default = config.build.toplevel.package // {
                      # TODO: not sure how i should insert the meta data yet all i want to do is echo metadata
                    };
                    description = ''
                      internal tooling so that we can inject extra info like meta data.
                    '';
                  };
                };
                packageCheck = {
                  enable = mkEnableOption "" // {
                    description = "We only want this to be enabled if testScript is defined";
                    default = options.build.packageCheck.package.isDefined;
                  };
                  package = mkOption {
                    type = raw;
                    description = ''
                      This is a self enclosed package that tests other indivudal files or package.
                      write your derivations expecting failureContext to be available for logging
                      example ({failureContext?"noLogSet"}:{}) this will be invoked with
                        pkgs.callPackage () {inherit failureContext;}
                    '';
                  };
                };
              };
              eval = {
                warning = {
                  enable = mkEnableOption "" // {
                    description = "We only want this to be enabled if testScript is defined";
                    default = config.vm.testScript.isDefined;
                  };
                  is = mkOption { type = bool; };
                };
                assertion = {
                  enable = mkEnableOption "" // {
                    description = "We only want this to be enabled if testScript is defined";
                    default = options.eval.assertion.is.isDefined;
                  };
                  is = mkOption { type = bool; };
                };
              };
              meta = {
                maintainers = mkOption {
                  type = listOf raw;
                  description = "This options is for knowledge of maintainers and is not evaluated";
                };
                failureContext = mkOption {
                  type = attrs;
                  description = "Used during eval time and is displayed each item as a newline, also provides the ability to filter via nix in the future";
                };
                testData = mkOption {
                  type = attrs;
                  description = "Used during eval time and is displayed each item as a newline, also provides the ability to filter via nix in the future";
                };
              };
            };
          }
        )
      );
    };
  };
}
