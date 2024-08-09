{ lib
,
}: {
  failedAssertions = listOfAttrs: map (x: x.message) (builtins.filter (x: !x.assertion) listOfAttrs);
  regulaToAssertion = x: mode:
    (builtins.filter (x: (x.enable && x.mode == mode))
    (lib.mapAttrsToList (n: v:
    (if v.verboseMessage != "" then builtins.traceVerbose v.verboseMessage v
    else v)) x));

}
