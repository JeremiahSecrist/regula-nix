{
  modulesPath,
  options,
  config,
  lib,
  pkgs,
  ...
}:
{
  fileSystems."/".device = "/dev/null";
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.openssh.enable = true;

  regula = {
    enable = true;
    features = {
      nixosTesting.enable = true;
      assertions.enable = true;
      packageChecks.enable = true;
    };
    rules = {
      mo = {
        tests = {
          eval.assertion.is = config.services.openssh.enable;
          vm.testScript = ''
            with subtest("""@discovery"""):
              machine.wait_for_unit("sshd.service")
              machine.succeed("systemctl is-active -q sshd.service")
          '';
          build.packageCheck.package =
            {
              discovery,
              cowsay,
              runCommandNoCCLocal,
            }:
            runCommandNoCCLocal "sample-test"
              {
                buildInputs = [ cowsay ];
                inherit discovery;
              }
              # bash
              ''
                cowsay "''${discovery}" | tee -a $out
              '';
        };
        meta.discovery = {
          path = builtins.toString ./test-system.nix;
          A = "HI";
          name = "mo";
        };
      };

    };
  };
  system.stateVersion = "${config.system.nixos.release}";
}
