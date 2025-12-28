{ lib, system, ... }:

let
  isDarwin = lib.hasSuffix "-darwin" system;
in
{
  imports = lib.optionals (!isDarwin) [
    ./easyeffects
    ./ollama.nix
    ./syncthing.nix
  ];
}
