# Options

## Example usage

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
    cfg = config.security.regula-nix.profiles.CIS.NixOS-Linux-Benchmark.v2_0_0;
    shorthand = security.regula-nix.profiles.CIS.NixOS-Linux-Benchmark.v2_0_0;
    regulaNixLib = config.regula-nix.lib;
in {

    options.security.regula-nix = {
        profiles = {
            CIS.NixOS-Linux-Benchmark.v2_0_0 = {
                enable = regulaNixLib.mkEnableOption "NixOS-Linux-Benchmark.v2_0_0" ;
                rules = regulaNixLib.mkRules "NixOS-Linux-Benchmark.v2_0_0-rules";
            };
        };
    };

    config = mkif cfg.enable {
        # global rules that can be accessed across 
        security.regula.rules = {
            c6b278fa-b69e-4700-bdc2-8f0fdb61c9ed = {

            };
        };
        # Where the rules can be applied
        security.regula-nix.profiles.CIS.NixOS-Linux-Benchmark.v2_0_0.rules = [
             
        ];

    };
}
```