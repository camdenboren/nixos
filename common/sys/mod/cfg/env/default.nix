{
  lib,
  system,
  hostname,
  ...
}:

let
  isLinux = lib.hasSuffix "-linux" system;
in
{
  imports = [
    ./nix-settings.nix
    ../../../../ovy
  ]
  ++ lib.optionals isLinux [
    ./sessionVariables.nix
  ]
  ++ lib.optionals (hostname == "main" || hostname == "media") [
    ./etc.nix
    ./travel.nix
  ];
}
