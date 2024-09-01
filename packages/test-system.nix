{
  modulesPath,
  # options,
  config,
  # lib,
  # pkgs,
  ...
}:
{
  imports = [ "${modulesPath}/profiles/headless.nix" ];
  fileSystems."/".device = "/dev/null";
  # boot.loader = {
  #   systemd-boot.enable = true;
  #   efi.canTouchEfiVariables = true;
  # };
  services.openssh.enable = true;

  # Remove perl from activation
  boot.initrd.systemd.enable = true;
  system = {
    etc.overlay.enable = true;
    switch = {
      enable = false;
      enableNg = true;
    };
    disableInstallerTools = true;
  };
  programs = {
    less.lessopen = null;
    command-not-found.enable = false;
  };
  boot = {
    enableContainers = false;
    loader.grub.enable = false;
  };
  environment.defaultPackages = [ ];
  documentation.info.enable = false;

  regula = {
    enable = true;
    features = {
      nixosTesting.enable = true;
      assertions.enable = true;
      packageChecks.enable = true;
      toplevel.enable = true;
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
        build = {

          toplevel.package =
            {
              # deadnix: skip
              testData ? { },
              # failureContext ? "a",
              cowsay,
              writeShellApplication,
            }:
            writeShellApplication {
              name = "toplevel-test";
              runtimeInputs = [ cowsay ];
              text = ''cowsay moo'';
            };
          packageCheck.package =
            {
              # deadnix: skip
              testData ? { },
              failureContext ? "a",
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
        };
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
