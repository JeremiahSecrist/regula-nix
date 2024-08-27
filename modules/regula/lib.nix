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
  extractAttr = inp: inp / (mapAttrsToList (n: v: v));
  extractAttrWithName = inp: inp / (mapAttrsToList (n: v: v // { name = n; }));
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
  out = {
    inherit attrsToMessage;
    mapChecksToScripts =
      regulaRules: regulaRules / extractAttr / (filter (x: (!x.enable && x.assertion)));

    failedAssertionsToListOfStr =
      listOfAttrs: listOfAttrs / out.showFailedAssertion / (map (x: x.message));

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
      / (filter (x: x.enable && x.tests.build.packageCheck.enable))
      / (map (
        x:
        (pkgs.callPackage x.tests.build.packageCheck.package {
          discovery = (attrsToMessage x.meta.discovery);
        })
      ));
    regulaToAssertion =
      x: name:
      x
      / mapAttrsToList (
        n: v: {
          inherit (v.tests.eval.assertion) enable;
          assertion = (if v.tests.eval.${name}.enable then v.tests.eval.${name}.is else true);
          message = (attrsToMessage v.meta.discovery);
        }
      )
      / filter (x: (x.enable));

    regulaToSelfNixOSTestBuilder = {
      script =
        inp:
        inp
        / extractAttr
        / (filter (x: (x.enable && x.tests.vm.enable)))
        / (map (x: x.tests.vm._testScriptCompiled))
        / (concatStringsSep "\n");
      config =
        inp:
        inp
        / extractAttr
        / (filter (x: (x.enable)))
        / (map (x: if x.vm ? extraVmConfig then x.tests.vm.extraVmConfig else { }));
    };

    showFailedAssertion = x: filter (y: !y.assertion) x;
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
        inherit testScript;
      };
  };
in
out
