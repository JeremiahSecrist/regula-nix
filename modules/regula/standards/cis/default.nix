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
    imports = [
        ./fileSystems
    ];
    options.regula.cis.enable = mkEnableOption "This enables the regula module";
    config = mkIf cfg.enable {
        # assertions = [

        # ];
    };
}
