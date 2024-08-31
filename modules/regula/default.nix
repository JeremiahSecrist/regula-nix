{
  options,
  config,
  lib,
  pkgs,
  modules,
  baseModules,
  extraModules,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.regula;
  rlib = import ./lib.nix { inherit lib pkgs; };
  baseConditions = options.regula.rules.isDefined && cfg.enable;
in
{
  options = import ./options.nix {
    inherit
      pkgs
      lib
      rlib
      config
      options
      ;
  };
  config = mkMerge [
    {
      assertions = [ ];
      warnings = rlib.failedAssertionsToListOfStr [
        {
          message = "rules is empty, please enable a module that uses regula.rules";
          assertion = options.regula.rules.isDefined;
        }
        {
          message = "regula: no validators are enabled.";
          assertion = baseConditions
            -> !(
              cfg.features.toplevel.enable
              && cfg.features.packageChecks.enable
              && cfg.features.assertions.enable
              && cfg.features.warnings.enable
              && cfg.features.nixosTest.enable
            );
        }
      ];
    }
    (mkIf (baseConditions && cfg.features.nixosTesting.enable && (!config ? testing)) {
      system.checks = [
        (pkgs.callPackage rlib.mkNixOSTest {
          inherit modules baseModules extraModules;
          testScript = rlib.regulaToSelfNixOSTestBuilder.script config.regula.rules;
          testOnlyConfigs = [ ];
        })
      ];
    })

    /**
      we have access tp the toplevel nixos derivation and
      offers static analysis to the entire config
    */
    (mkIf baseConditions {
      /**
        extraSystemBuilderCmds is an internal feature
        not shown in the docs for some reason
        super useful and gives us access to the final package before the build finishes
      */
      system.extraSystemBuilderCmds =
        # Ideally here we map scripts with a message and compare the success or failure
        ''
          ${pkgs.writeScript "checkPhase" ''
            FAIL=0
            check() {
              message="$1"
              shift
              command="$@"
              eval "$command"
              if [ $? -ne 0 ]; then
                  echo "Check failed: ''${command} ''${message}"
                FAIL=1
              fi
            }
            exit ''${FAIL}
          ''}
        '';
    })

    /**
      This provides access to inspect specific outputs via the runlocalcommand
      one needs to know the module structure to test a specific store path
    */
    (mkIf (baseConditions && cfg.features.packageChecks.enable) {
      system.checks = rlib.regulaToPackageChecks config.regula.rules;
    })

    /**
      Ideally we would want a way to disable each portion depending on the user
      This section sspecifically implements warnings into the system at the toplevel
    */
    (mkIf (baseConditions && cfg.features.warnings.enable) {
      warnings =
        # This makes warnings behave like assertions as a datastructure
        rlib.failedAssertionsToListOfStr (rlib.regulaToAssertion config.regula.rules "warning");
    })

    /**
      Same as warnings but will fail the build right away
    */
    (mkIf (baseConditions && cfg.features.assertions.enable) {
      assertions = rlib.regulaToAssertion config.regula.rules "assertion";
    })

  ];

}
