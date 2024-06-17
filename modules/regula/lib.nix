{
  lib,
  pkgs ? null,
}: {
    mkAssertions = listOfProfiles: (
    lib.unique # remove duplicate assertions
    (
      builtins.filter (x: x.mode == 2) # mode 2 meants assert TODO: make warn system
      (
        lib.flatten # gets rid of nested lists
        listOfProfiles # should point to enabledProfiles
      )
    )
  );
  mkAssertions = profiles: concatMap (org: concatMap (profile: [
      {
        assertion = profile.rules != null;
        message = "Profile ${toString profile} for organization ${toString org} has no rules defined.";
      }
    ]) profiles) (builtins.attrNames config.regula.organizations);

    mkWarns = listOfProfiles: (
    lib.unique # remove duplicate assertions
    (
      builtins.filter (x: x.mode == 1 or x.assertion == false) # mode 2 meants assert TODO: make warn system
      (
        lib.flatten # gets rid of nested lists
        listOfProfiles.message # should point to enabledProfiles
      )
    )
  };
}