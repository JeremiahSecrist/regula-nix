{ lib, pkgs, }: rec {
  mapListOfAttrsStringOfnl = inp: (lib.concatStringsSep "\n" (lib.flatten (builtins.map (x: (lib.mapAttrsFlatten (n: v: "${n}: ${v}") x)) inp)));
  failedAssertionsToListOfStr = listOfAttrs:
    map (x: x.message) (builtins.filter (x: !x.assertion) listOfAttrs);
  regulaToAssertion = x: mode:
    (builtins.filter (x: (x.enable && x.mode == mode)) (lib.mapAttrsToList
      (n: v:
        (if v.verboseMessage != "" then
          builtins.traceVerbose v.verboseMessage v
        else
          { inherit (v) mode enable assertion; message = (mapListOfAttrsStringOfnl v.meta.discovery); }))
      x));
  checkFile =
    { runCommandLocal ? pkgs.runCommandLocal
    , name
    , nativeBuildInputs ? [ ]
    , script ? ""
    , file ? ""
    }:
    runCommandLocal name
      {
        inherit nativeBuildInputs file;
        passAsFile = [ "file" ];
      } # sh
      script;
  flakeModulePath = builtins.toString ../.;
}
