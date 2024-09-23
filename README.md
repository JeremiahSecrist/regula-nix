# Regula-nix

![Under Construction](https://img.shields.io/badge/Under_Construction-%E2%9A%A0%EF%B8%8F-%23E65100?style=for-the-badge&logo=warning&logoColor=%23BF360C&labelColor=%23E65100) [![Check flake](https://github.com/JeremiahSecrist/regula-nix/actions/workflows/checks.yml/badge.svg)](https://github.com/JeremiahSecrist/regula-nix/actions/workflows/checks.yml)

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
        eval.assertion.is = config.services.openssh.enable;
        build = {
            toplevel = {testData, failureContext}:{}; #a script that must return true when run against nixos output
            perPackage = {testData, failureContext }:{}; # derivation that must build successfully.
        };
        vm = {
            # This uses pytest with intergrations to the boot lifecycle of the system.
            testScript = ''
                with subtest("sshd must be enabled"):
                    machine.wait_for_unit("sshd.service")
                    machine.succeed("systemctl is-active -q sshd.service")
            '';
        };
        # extra info and data about this test that is available when relevant.
        meta = {
            # failureContext becomes a multiline string that is useful
            failureContext = {
                name = "openssh is not enabled";
            };
            # testData is available un alterd for use in relevant functions.
            testData = {
                example = "foo";
            };
        };
    };
};
}
```

## Star History

<a href="https://star-history.com/#JeremiahSecrist/regula-nix&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=JeremiahSecrist/regula-nix&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=JeremiahSecrist/regula-nix&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=JeremiahSecrist/regula-nix&type=Date" />
 </picture>
</a>
