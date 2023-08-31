{
config,
lib,
pkgs,
...
}:
let
    inherit (lib) mkIf mkEnableOption mkOption types;
    cfg = config.regula;

    mkBlacklistedFilesystem = modules: map (x: {
                assertion = builtins.elem "${x}" config.boot.blacklistedKernelModules;
                message = "CIS: 1.1.1.x boot.blacklistedKernelModules must contain ${x}";
            }) modules;

    unusedFilesystems = mkBlacklistedFilesystem [
        "cramfs"
        "freevxf"
        "jffs2"
        "hfs"
        "hfsplus"
        "squashfs"
        "udf"
        "vfat"
    ];

    mkMountAsserts = mounts: map (x: {
                assertion = builtins.hasAttr "${x}" config.fileSystems;
                message = "CIS 1.1.x ${x} must be mounted seperately";
            }) mounts;

    mountAsserts = mkMountAsserts [
        "/tmp"              # 1.1.4
        "/var"              # 1.1.6
        "/var/tmp"          # 1.1.7
        "/var/log"          # 1.1.11
        "/var/log/audit"    # 1.1.12
        "/home"             # 1.1.13
        "/dev/shm"          # 1.1.15
        ];
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
        assertions = unusedFilesystems ++ mountAsserts;
    };
}
