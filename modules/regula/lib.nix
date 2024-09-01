{ lib, pkgs }:

let
  inherit (lib)
    # mkIf
    getExe
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
  # deadnix: skip
  __div = x: y: y x; # Will remove when pipes (|>) are in mainline

in
rec {
  /**
    test
  */
  extractAttr = inp: inp / (mapAttrsToList (_n: v: v));
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

  failedAssertionsToListOfStr = inp: inp / showFailedAssertion / (map (x: x.message));

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
        failureContext = attrsToMessage x.meta.failureContext;
        inherit (x.meta) testData;
      })
    ));
  /**
    type:
  */
  regulaToAssertion =
    x: name:
    x
    / mapAttrsToList (
      _n: v: {
        inherit (v.eval.assertion) enable;
        assertion = if v.eval.${name}.enable then v.eval.${name}.is else true;
        message = attrsToMessage v.meta.failureContext;
      }
    )
    / filter (x: x.enable);
  regulaToToplevelCheck =
    inp:
    inp
    # The usual format I want the data in.
    / extractAttr
    # Filter by only ones that are enabled. This is paired with a collector in the ./options.nix
    / (filter (x: (x.enable && x.build.toplevel.enable)))
    # we extract only the final package with an future changes made available.
    / (map (
      x:
      "check \"${attrsToMessage x.meta.failureContext}\" ${
        getExe (pkgs.callPackage x.build.toplevel.package { })
      } "
    ))
    / (concatStringsSep "\n");
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
      inp / extractAttr / (filter (x: (x.enable && x.vm.enable))) / (map (x: x.vm.extraVmConfig or { }));
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
