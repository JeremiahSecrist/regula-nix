{
  options,
  config,
  lib,
  pkgs,
  # modules in this context is user defined modules
  modules,
  /**
    baseModules in this context is
    provided typically by nixpkgs that invoked this system
  */
  baseModules,
  # i've never seen extra modules use in the wild but better safe than sorry.
  extraModules,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.regula;
  rlib = import ./lib.nix { inherit lib pkgs; };
  /**
    in our situation one could enable the module but not a ruleset
    as such we chould not enable anything unless a rule is declared
    with eception for assertions and warnings that check the rule structure
  */
  baseConditions = (options.regula.rules.isDefined && cfg.enable);
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
      assertions = [

      ];
      warnings = rlib.failedAssertionsToListOfStr [
        {
          message = "rules is empty, please enable a module that uses regula.rules";
          assertion = (options.regula.rules.isDefined);
        }
        {
          message = "regula: no validators are enabled.";
          assertion = (
            baseConditions
            -> !(
              cfg.features.toplevel.enable
              && cfg.features.packageChecks.enable
              && cfg.features.assertions.enable
              && cfg.features.warnings.enable
              && cfg.features.nixosTest.enable
            )
          );
        }
      ];
    }
    /**
      we only want the virutalization test to run once, otherwise we get inifite recursion that isnt detected by nix.
      furthermore testing only exists in a testing environment but it may be better to have an explicit option to prevent accidental disabling?
    */
    (mkIf (baseConditions && cfg.features.nixosTesting.enable && (!config ? testing)) {
      # we add this to system checks as it does not get revealed in path.
      system.checks = [
        (pkgs.callPackage rlib.mkNixOSTest {
          inherit modules baseModules extraModules;
          # need a way to bring in the error messages
          testScript = (rlib.regulaToSelfNixOSTestBuilder.script config.regula.rules);
          testOnlyConfigs = [ ];
        })
      ];
    })

    /**
      we have access tp the toplevel nixos derivation and
      offers static analysis to the entire config
    */
    (mkIf (baseConditions) {
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
      system.checks = (rlib.regulaToPackageChecks config.regula.rules);
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
      assertions = (rlib.regulaToAssertion config.regula.rules "assertion");
    })

  ];

}
