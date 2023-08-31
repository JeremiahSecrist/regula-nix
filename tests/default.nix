{
self,
inputs,
pkgs,
...
}:
let
  # NixOS module shared between server and client
  sharedModule = {
    # Since it's common for CI not to have $DISPLAY available, we have to explicitly tell the tests "please don't expect any screen available"
    virtualisation.graphics = false;
  };
  nixpkgs = inputs.nixpkgs;
in pkgs.nixosTest {
    name = "basic test";
    nodes.machine = { config, pkgs, ...}: {
      imports = [
        self.nixosModules.regula
      ];
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      regula.enable = true;
      system.stateVersion = "23.05";
    };

    testScript = {nodes, ...}: ''
      # machine.wait_for_unit("default.target")
      # machine.succeed("su -- jane -c 'which firefox'")
      # machine.fail("su -- root -c 'which firefox'")
    '';
  }
