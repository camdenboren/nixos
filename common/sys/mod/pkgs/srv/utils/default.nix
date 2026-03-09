{ lib, hostname, ... }:

let
  isVM = lib.hasSuffix "vm" hostname;
in
{
  imports = [
    ./mullvad.nix
    ./openssh.nix
  ]
  ++ lib.optionals (!isVM) [
    ./shutdown.nix
  ];
}
