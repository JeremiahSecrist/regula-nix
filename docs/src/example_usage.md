# Example Usage

### End user
```nix
{
    security.regula = {
        enable = true;
        profiles = {
            CIS = { # Organization
                NixOS-Linux-Benchmark = { # Variant
                    v2_0_0.enable = true; # version
                };
            };
        };
    };
}
```

### Defensive Security Developer

#### Main module
```nix
{lib}: with lib;
let
    cfg = config.regula.profiles.CIS.NixOS-Linux-Benchmark.v2_0_0;
in {

    config = mkif cfg.enable {
    regula.rules = {
        varMustBeSeperated = { # by being a submodule it becomes easy to reuse
            enable = true;
            message = ""; # the message to display when the assertion or buildValidation fails
            assertion = false; # this is a bool that can be any logic
            buildValidation = {
                name = "the name of the script";
                nativeBuildInputs = []; # list of packages the script should have in its path
                file = pkgs.name.out; # any nix store path to run the evaluation on
            };
            #enum of assertion, warning, buildValidation
            mode = "";
        };
    };
    };
}
```
