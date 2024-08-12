{ lib, pkgs, }:
let
  __div = (x: y: y x);
in
rec {
  showFailedAssertion = x: builtins.filter (y: !y.assertion) x;
  mapListOfAttrsStringOfnl = inp:  (inp / (builtins.map (x: (lib.mapAttrsFlatten (n: v: "${n}: ${v}") x) )) / lib.flatten) / (x: lib.concatStringsSep "\n" x);
  failedAssertionsToListOfStr = listOfAttrs: listOfAttrs / showFailedAssertion / (i: map (x: x.message) i);
  regulaToAssertion = x: mode: x /
  lib.mapAttrsToList (n: v: { inherit (v) mode enable assertion; message = mapListOfAttrsStringOfnl v.meta.discovery;})
  / builtins.filter (x: x.enable && x.mode == mode);
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
