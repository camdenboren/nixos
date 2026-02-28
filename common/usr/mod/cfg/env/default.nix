{
  lib,
  system,
  hostname,
  ...
}:

let
  isLinux = lib.hasSuffix "-linux" system;
  isVM = lib.hasSuffix "vm" hostname;
in
{
  imports = [
    ./files.nix
    ./home-manager.nix
    ./nix-settings.nix
  ]
  ++ lib.optionals isLinux [
    ./sessionVariables.nix
  ]
  ++ lib.optionals isVM [
    ./xdg.nix
  ];
}
