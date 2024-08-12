{ self, pkgs, ... }:
let
  # NixOS module shared between server and client
  sharedModule = {
    # Since it's common for CI not to have $DISPLAY available, we have to explicitly tell the tests "please don't expect any screen available"
    virtualisation.graphics = false;
    imports = [ self.nixosModules.regula ];
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    regula.enable = true;
    # regula.profiles.cis.server-1.enable = true;
    system.stateVersion = "23.05";

  };
in
pkgs.testers.runNixOSTest {
  name = "basic test";
  nodes.machine = { config, pkgs, ... }: {
    imports = [ sharedModule ];
  };

  testScript = { nodes, ... }: "";
}
