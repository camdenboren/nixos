{
  pkgs,
  lib,
  system,
  hostname,
  ...
}:

let
  isDarwin = lib.hasSuffix "-darwin" system;
in
{
  home.packages =
    with pkgs;
    [
      # Content creation
      gimp
      inkscape
    ]
    ++ lib.optionals isDarwin [
      libreoffice-bin
    ]
    ++ lib.optionals (!isDarwin) [
      libreoffice
    ]
    ++ lib.optionals (hostname == "main") [
      blender
      darktable
      handbrake
    ]
    ++ lib.optionals (isDarwin || hostname == "main") [
      reaper
    ];
}
