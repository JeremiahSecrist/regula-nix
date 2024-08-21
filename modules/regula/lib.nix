{ lib, pkgs }:
let
  __div = (x: y: y x); # Will remove when pipes (|>) are in mainline
in
rec {
  regulaToSelfNixOSTestBuilder = {
    script =
      inp:
      inp
      / (lib.mapAttrsToList (n: v: v))
      / (builtins.filter (x: (x.enable && x.mode == "nixosTest")))
      / (builtins.map (x: x.vm.testScript))
      / (lib.concatStringsSep "\n");
    config =
      inp:
      inp
      / (lib.mapAttrsToList (n: v: v))
      / (builtins.filter (x: (x.enable && x.mode == "nixosTest")))
      / (builtins.map (x: if x.vm.extraVmConfig != null then x.vm.extraVmConfig else {}));
  };
  selfNixOSTestBuilder =
    {
      testOnlyConfigs ? [ ],
      testScript ? "",
      modules,
      baseModules,
      extraModules,
    }:
    pkgs.testers.runNixOSTest {
      name = "Regula preflight";
      nodes = {
        machine =
          { ... }:
          {
            imports = builtins.concatLists [
              modules
              baseModules
              extraModules
              testOnlyConfigs
            ];
          };
      };
      inherit testScript;
    };

  mapChecksToScripts =
    regulaRules:
    regulaRules / (lib.mapAttrsToList (n: v: v)) / (builtins.filter (x: (!x.enable && x.assertion)));

  showFailedAssertion = x: builtins.filter (y: !y.assertion) x;

  mapListOfAttrsStringOfnl =
    inp:
    inp
    / builtins.map (lib.mapAttrsFlatten (n: v: "${n}: ${v}"))
    / lib.flatten
    / (x: lib.concatStringsSep "\n" x);

  failedAssertionsToListOfStr = listOfAttrs: listOfAttrs / showFailedAssertion / (map (x: x.message));

  regulaToAssertion =
    x: mode:
    x
    / lib.mapAttrsToList (
      n: v: {
        inherit (v) mode enable assertion;
        message = mapListOfAttrsStringOfnl v.meta.discovery;
      }
    )
    / builtins.filter (x: x.enable && x.mode == mode);

  checkFile =
    {
      runCommandLocal ? pkgs.runCommandLocal,
      name,
      nativeBuildInputs ? [ ],
      script ? "",
      file ? "",
    }:
    runCommandLocal name
      {
        inherit nativeBuildInputs file;
        passAsFile = [ "file" ];
      } # sh
      script;

  flakeModulePath = builtins.toString ../.;
}
