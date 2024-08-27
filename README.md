# Regula-nix

![Under Construction](https://img.shields.io/badge/Under_Construction-%E2%9A%A0%EF%B8%8F-%23E65100?style=for-the-badge&logo=warning&logoColor=%23BF360C&labelColor=%23E65100)

A NixOS module aimed at making provable security compliance accessible and maintainable.
Pushing compliance checking to the left.

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
# Status

[![Check flake](https://github.com/JeremiahSecrist/regula-nix/actions/workflows/checks.yml/badge.svg)](https://github.com/JeremiahSecrist/regula-nix/actions/workflows/checks.yml)
