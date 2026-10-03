{
  pkgs,
  lib,
  system,
  ...
}:

let
  isDarwin = lib.hasSuffix "-darwin" system;
in
{
  environment.systemPackages = with pkgs; [
    sqlite
  ];

  imports = lib.optionals (!isDarwin) [
    ./fonts.nix
  ];
}
