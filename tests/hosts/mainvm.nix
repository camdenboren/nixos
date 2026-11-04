{
  nixosConfiguration,
  pkgs,
}:

pkgs.testers.runNixOSTest {
  name = "mainvm";
  imports = [
    (import ../smoke.nix {
      inherit pkgs nixosConfiguration;
      checkExtraServices = true;
    })
  ];
}
