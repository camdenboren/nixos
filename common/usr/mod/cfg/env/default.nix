{
  lib,
  system,
  ...
}:

let
  isLinux = lib.hasSuffix "-linux" system;
in
{
  imports = [
    ./files.nix
    ./home-manager.nix
    ./nix-settings.nix
    ../../../../ovy
  ]
  ++ lib.optionals isLinux [
    ./sessionVariables.nix
    ./xdg.nix
  ];
}
