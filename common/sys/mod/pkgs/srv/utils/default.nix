{ lib, hostname, ... }:

let
  isVM = lib.hasSuffix "vm" hostname;
in
{
  imports = [
    ./openssh.nix
    ./home-manager-restart.nix
  ]
  ++ lib.optionals (!isVM) [
    ./fetch-rs.nix
    ./mullvad.nix
    ./shutdown.nix
    ./ups.nix
    ./vector.nix
  ];
}
