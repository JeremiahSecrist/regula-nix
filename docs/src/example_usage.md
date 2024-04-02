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
    cfg = config.security.regula-nix.profiles.CIS.NixOS-Linux-Benchmark.v2_0_0;
    regulaNixLib = config.regula-nix.lib;
in {

    options.security.regula-nix = {
        profiles = {
            CIS.NixOS-Linux-Benchmark.v2_0_0 = {
                enable = regulaNixLib.mkEnableOption "NixOS-Linux-Benchmark.v2_0_0" ;
                rules = regulaNixLib.mkRules "NixOS-Linux-Benchmark.v2_0_0-rules";
                description =  ''
                    A custom variant of cis benchmark tailored to nixos
                '';
            };
        };
    };

    config = mkif cfg.enable {
        # global rules that can be accessed across 
        security.regula.rules = {
            # This returns a function
            c6b278fa-b69e-4700-bdc2-8f0fdb61c9ed = {
                # 0 = inactive
                # 1 = warning
                # 2 = enforced
                # 3 = enforced with runtime check
                # 4 = runtime check without eval enforcement
                enforce = 0; 

                # This allows for runtime checks
                script = {
                    # runtime dependencies for the script, aka native buildinputs
                    packages = with pkgs; [
                        kmod
                        gnugrep
                    ];
                    content = ''
                        lsmod | grep -q cramfs
                    '';
                };

                meta = {
                    authors = [

                    ];
                    # This is a basic description of what it is checking and why
                    description = "";
                    # not meant to be filled here and is overridden at invocation
                    discovery = [
                        {
                            org = "CIS";
                            variant = "NixOS-Linux-Benchmark";
                            version = "v2_0_0";
                            location = "page 15";
                        }
                    ];
                };
            };
        };
        # Where the rules can be applied
        security.regula-nix.profiles.CIS.NixOS-Linux-Benchmark.v2_0_0.rules = 
            with config.security.regula.rules; [
                c6b278fa-b69e-4700-bdc2-8f0fdb61c9ed
            ];

    };
}
```