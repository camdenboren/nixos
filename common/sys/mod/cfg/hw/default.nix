{
  lib,
  hostname,
  system,
  ...
}:

let
  isLinux = lib.hasSuffix "-linux" system;
in
{
  imports = [
    ./networking.nix
  ]
  ++ lib.optionals isLinux [
    ./audio.nix
    ./printing.nix
    ./swap.nix
  ]
  ++ lib.optionals (isLinux && hostname != "media") [
    ./boot.nix
  ];
}
