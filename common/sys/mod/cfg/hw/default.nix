{ lib, hostname, ... }:

{
  imports =
    [
      ./audio.nix
      ./networking.nix
      ./printing.nix
    ]
    ++ lib.optionals (hostname != "media") [
      ./boot.nix
    ];
}
