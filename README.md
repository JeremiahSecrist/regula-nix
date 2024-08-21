# Regula-nix

A NixOS module aimed at making provable security compliance accessible and maintainable.

## Core concepts

Regula-nix offers a key NixOS module that when incorporated makes defining tests and restrictions about ones own config possible.


## Examples
```nix
{
regula.rules = {
    sshdMustBeEnabled = {
        enable = true;
        mode = "assertion";
        assertion = config.services.openssh.enable;
        meta = {
            discovery = [
                {
                    name = "openssh is not enabled";
                }
            ];
        };
    };
    sshdServiceMustRun = {
        enable = true;
        mode = "nixosTest";
        vm = {
            testScript = ''
                with subtest("sshd must be enabled"):
                    machine.wait_for_unit("sshd.service")
                    machine.succeed("systemctl is-active -q sshd.service")
            '';
        }
    };
};
}
```

