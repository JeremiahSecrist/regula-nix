{
config,
lib,
pkgs,
...
}:
let
    inherit (lib) mkIf mkEnableOption mkOption types;
    cfg = config.regula;
in {
    options = {
        regula = {
            cis = {
                filesystems = {
                    enable = mkEnableOption { default = config.regula.cis.enable; };
                };
            };
        };
    };
    config = mkIf cfg.enable {
        assertions = [
            #1.1.1.1 Ensure mounting of cramfs filesystems is disabled
            {
                asserttion = builtins.elm "cramfs" config.boot.blacklistedKernelModules;
                message = "boot.blacklistedKernelModules must contain cramfs";
            }
            # 1.1.1.2 Ensure mounting of freevxfs filesystems is disabled
            {
                asserttion = builtins.elm "freevxf" config.boot.blacklistedKernelModules;
                message = "boot.blacklistedKernelModules must contain freevxf";
            }
        ];
    };
}
