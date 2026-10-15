{
  lib,
  hostname,
  system,
  ...
}:

let
  isVM = lib.hasSuffix "vm" hostname;
  isLinux = lib.hasSuffix "-linux" system;
in
{
  imports = [
    ./networking.nix
  ]
  ++ lib.optionals isLinux [
    ./audio.nix
    ./printing.nix
  ]
  ++ lib.optionals (isLinux && !isVM) [
    ./swap.nix
  ]
  ++ lib.optionals (isLinux && hostname != "media") [
    ./boot.nix
  ];
}
