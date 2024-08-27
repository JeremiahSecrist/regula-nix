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
      # assertions.enable = true;
      packageChecks.enable = true;
    };
    # assertions.enable = true;
    # buildValidation.vmTest.enable = true;
    rules = {
      mo = {
        enable = true;
        tests = {
          eval.assertion.is = false;
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
      emo = {
        enable = true;
        tests = {
          # enable = true;
          vm.testScript = ''
            with subtest("""@discovery"""):
              machine.wait_for_unit("sshd.service")
              machine.succeed("systemctl is-active -q sshd.service")
          '';
        };
        meta.discovery = {
          path = builtins.toString ./test-system.nix;
          A = "HI";
        };
      };
      demo = {
        enable = true;
        tests = {
          # enable = true;
          vm.testScript = ''
            with subtest("""@discovery"""):
              machine.wait_for_unit("sshd.service")
              machine.succeed("systemctl is-active -q sshd.service")
          '';
        };
        meta.discovery = {
          path = builtins.toString ./test-system.nix;
          A = "HI";
        };
      };
    };
    # sshEnableForceRuntime = {
    #   enable = true;
    #   mode = "nixosTest";
    #   vm.testScript = ''
    #     with subtest("sshd must be enabled"):
    #       machine.wait_for_unit("sshd.service")
    #       machine.succeed("systemctl is-active -q sshd.service")
    #   '';
    # };
    # sshEnableForce = {
    #   enable = true;
    #   mode = "assertion";
    #   assertion = config.services.openssh.enable;
    #   meta = {
    #     discovery = [ { message = "openssh must be enabled!"; } ];
    #   };
    # };
    # };
  };

  assertions = [
    # {
    #   message = config.regula.rules.demo.tests.vm._testScriptCompiled;
    #   assertion = false;
    # }
  ];
  system.stateVersion = "${config.system.nixos.release}";
}
