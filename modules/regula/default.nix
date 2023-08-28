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
            enable = mkEnableOption "This enables the regula module";
        }
    };
    config = mkIf cfg.enable {
        assertions = [

        ];
    };
}
