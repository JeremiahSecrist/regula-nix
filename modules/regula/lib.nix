{ lib, pkgs, }:
let
  __div = (x: y: y x); # Will remove when pipes (|>) are in mainline
in
rec {
  showFailedAssertion = x: builtins.filter (y: !y.assertion) x;
  mapListOfAttrsStringOfnl = inp: inp / builtins.map (lib.mapAttrsFlatten (n: v: "${n}: ${v}")) / lib.flatten / (x: lib.concatStringsSep "\n" x);
  failedAssertionsToListOfStr = listOfAttrs: listOfAttrs / showFailedAssertion / (map (x: x.message));
  regulaToAssertion = x: mode: x /
    lib.mapAttrsToList (n: v: { inherit (v) mode enable assertion; message = mapListOfAttrsStringOfnl v.meta.discovery; })
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
