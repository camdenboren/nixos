{ lib, system, ... }:

let
  isDarwin = lib.hasSuffix "-darwin" system;
in
{
  imports = [
    ./ollama.nix
  ]
  ++ lib.optionals (!isDarwin) [
    ./easyeffects
  ];
}
