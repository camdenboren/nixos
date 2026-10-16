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
    unzip
    zip
  ];

  imports = lib.optionals (!isDarwin) [
    ./fonts.nix
  ];
}
