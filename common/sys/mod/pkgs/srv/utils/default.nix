{ lib, hostname, ... }:

let
  isVM = lib.hasSuffix "vm" hostname;
in
{
  imports = [
    ./openssh.nix
  ]
  ++ lib.optionals (!isVM) [
    ./mullvad.nix
    ./shutdown.nix
  ];
}
