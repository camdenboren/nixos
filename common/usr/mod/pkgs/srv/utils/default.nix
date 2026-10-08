{
  lib,
  hostname,
  system,
  ...
}:

let
  isDarwin = lib.hasSuffix "-darwin" system;
  isVM = lib.hasSuffix "vm" hostname;
in
{
  imports =
    lib.optionals (!isDarwin) [
      ./audio-prevents-lock.nix
    ]
    ++ lib.optionals (!isDarwin && !isVM) [
      ./easyeffects
      ./ollama.nix
      ./syncthing.nix
    ];
}
