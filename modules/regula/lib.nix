{ lib, pkgs }:

let
  inherit (lib)
    mkIf
    concatStringsSep
    generators
    replaceStrings
    mapAttrsToList
    ;
  inherit (builtins)
    concatLists
    toString
    filter
    map
    ;

  __div = (x: y: y x); # Will remove when pipes (|>) are in mainline

in
rec {
  /**
    test
  */
  extractAttr = inp: inp / (mapAttrsToList (n: v: v));
  extractAttrWithName = inp: inp / (mapAttrsToList (n: v: v // { name = n; }));
  showFailedAssertion = x: filter (y: !y.assertion) x;
  attrsToMessage =
    inp:
    inp
    / (generators.toPretty { })
    / (replaceStrings
      [
        " ="
        ";"
        "{"
        "}"
        "\""
        "["
        "]"
      ]
      [
        ":"
        ""
        ""
        ""
        ""
        ""
        ""
      ]
    );
  mapChecksToScripts =
    regulaRules: regulaRules / extractAttr / (filter (x: (!x.enable && x.assertion)));

  failedAssertionsToListOfStr = listOfAttrs: listOfAttrs / showFailedAssertion / (map (x: x.message));

  checkFile =
    {
      runCommandLocal,
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

  flakeModulePath = toString ../.;
  regulaToPackageChecks =
    inp:
    inp
    / extractAttrWithName
    / (filter (x: x.enable && x.build.packageCheck.enable))
    / (map (
      x:
      (pkgs.callPackage x.build.packageCheck.package {
        failureContext = (attrsToMessage x.meta.failureContext);
        testData = (attrsToMessage x.meta.testData);
      })
    ));
  /**
    type:
  */
  regulaToAssertion =
    x: name:
    x
    / mapAttrsToList (
      n: v: {
        inherit (v.eval.assertion) enable;
        assertion = (if v.eval.${name}.enable then v.eval.${name}.is else true);
        message = (attrsToMessage v.meta.failureContext);
      }
    )
    / filter (x: x.enable);

  regulaToSelfNixOSTestBuilder = {
    script =
      inp:
      inp
      / extractAttr
      / (filter (x: (x.enable && x.vm.enable)))
      / (map (x: x.vm._testScriptCompiled))
      / (concatStringsSep "\n");
    config =
      inp:
      inp
      / extractAttr
      / (filter (x: x.enable))
      / (map (x: if x.vm ? extraVmConfig then x.vm.extraVmConfig else { }));
  };
  /**
    type:
  */
  mkNixOSTest =
    {
      testers,
      testOnlyConfigs ? [ ],
      testScript ? "",
      modules,
      baseModules,
      extraModules,
    }:
    testers.runNixOSTest {
      name = "Regula preflight";
      nodes = {
        machine =
          { ... }:
          {
            imports = concatLists [
              modules
              baseModules
              extraModules
              testOnlyConfigs
            ];
          };
      };
      /**
        # important
      */
      inherit testScript;
    };
}
