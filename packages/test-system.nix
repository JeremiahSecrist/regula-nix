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
        eval.assertion.is = config.services.openssh.enable;
        vm = {
          testScript = ''
            with subtest("""@failureContext"""):
              machine.wait_for_unit("sshd.service")
              machine.succeed("systemctl is-active -q sshd.service")
          '';
        };
        build.packageCheck.package =
          {
            testData,
            failureContext,
            cowsay,
            runCommandNoCCLocal,
          }:
          runCommandNoCCLocal "sample-test"
            {
              inherit failureContext;
              buildInputs = [ cowsay ];
            }
            # bash
            ''
              cowsay "''${failureContext}" | tee -a $out
            '';
        # rawNix -> prettified -> brought into error handling
        # TODO implement new names
        meta = {
          failureContext = {
            declaredIn = builtins.toString ./test-system.nix;
            A.b = "HI";
            name = "mo";
          };
          testData = {

          };
        };
      };

    };
  };
  system.stateVersion = "${config.system.nixos.release}";
}
