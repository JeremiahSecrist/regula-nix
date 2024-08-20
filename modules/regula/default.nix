{
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
  inherit (lib)
    mkIf
    mkMerge
    isAttrs
    mapAttrsToList
    ;
  cfg = config.regula;
  rlib = import ./lib.nix { inherit lib pkgs; };
  /**
    in our situation one could enable the module but not a ruleset
    as such we chould not enable anything unless a rule is declared
    with eception for assertions and warnings that check the rule structure
  */
  baseConditions = (cfg.enable && (isAttrs cfg.rules));
in
{

  options = import ./options.nix { inherit lib; };
  config = mkMerge [
    {
      assertions = [

      ];
      warnings = rlib.failedAssertionsToListOfStr [
        {
          message = "rules is empty, please enable a module that uses regula.rules";
          assertion = (isAttrs cfg.rules);
        }
      ];
    }
    /**
      we only want the virutalization test to run once, otherwise we get inifite recursion that isnt detected by nix.
      furthermore testing only exists in a testing environment but it may be better to have an explicit option to prevent accidental disabling?
    */
    (mkIf (baseConditions && cfg.buildValidation.vmTest.enable && (!config ? testing)) {
      # we add this to system checks as it does not get revealed in path.
      system.checks = [
        (rlib.selfNixOSTestBuilder {
          # the modules are exposed at the toplevel of the module system and we bring them back into this test environment to become a similar config to the host
          inherit modules baseModules extraModules;
          testScript = ''

          '';
          # we have this available to fix any issue that arrise from a config being virtualized
          testOnlyConfigs = [

          ];
        })
      ];
    })

    /**
      we have access tp the toplevel nixos derivation and
      offers static analysis to the entire config
    */
    (mkIf (baseConditions && cfg.buildValidation.system.enable) {
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
    (mkIf (baseConditions && cfg.buildValidation.perPackage.enable) { system.checks = [ ]; })

    /**
      Ideally we would want a way to disable each portion depending on the user
      This section sspecifically implements warnings into the system at the toplevel
    */
    (mkIf (baseConditions && cfg.warnings.enable) {
      warnings =
        # This makes warnings behave like assertions
        rlib.failedAssertionsToListOfStr [ ];
    })

    /**
      Same as warnings but will fail the build right away
    */
    (mkIf (baseConditions && cfg.assertions.enable) {
      assertions = (rlib.regulaToAssertion config.regula.rules "assertion");
    })

  ];

}
#   mkIf cfg.enable {
#     warnings = mkIf (builtins.isAttrs config.regula.rules) (
#       rlib.failedAssertionsToListOfStr (rlib.regulaToAssertion config.regula.rules "warning")
#     );
#     assertions = mkIf (builtins.isAttrs config.regula.rules) (
#       [
#         {
#           assertion = (
#             0 == (lib.length (
#               builtins.filter (x: (x.mode == "warning" && x.buildValidation != null)) (
#                 lib.mapAttrsToList (n: v: v) cfg.rules
#               )
#             ))
#           );
#           message = "can't use build validator with warning";
#         }
#       ]
#       ++
#     );
#     system.checks = mkIf (builtins.isAttrs config.regula.rules) (
#       [
#         (pkgs.testers.runNixOSTest {
#           name = "Regula vm test suite";
#           # extraBaseModules = modules;
#           nodes.main =
#             { config, pkgs, ... }:
#             {
#               imports = ((lib.init (lib.init modules)) ++ [ (lib.last modules) ]);
#             };
#           testScript =
#             { nodes, ... }:
#             ''
#               machine.wait_for_unit("default.target")
#               machine.succeed("$(systemctl is-active --quiet sshd)")
#             '';
#         })
#       ]
#       ++ (map (x: (rlib.checkFile x.buildValidation)) (
#         builtins.filter (x: (x.mode == "buildValidation" && x.enable)) (mapAttrsToList (n: v: v) cfg.rules)
#       ))
#     );
#
#   };
# }
