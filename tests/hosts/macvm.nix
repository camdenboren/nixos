{
  nixosConfiguration,
  pkgs,
}:

pkgs.testers.runNixOSTest {
  name = "macvm";
  imports = [
    (import ../smoke.nix {
      inherit pkgs nixosConfiguration;
    })
  ];

  # no kvm on gh runner
  requiredFeatures.kvm = false;
  qemu.forceAccel = false;
}
