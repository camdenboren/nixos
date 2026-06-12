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
    #[
    # Content creation
    #inkscape - broken on darwin at the moment
    #]
    #++ lib.optionals isDarwin [
    lib.optionals isDarwin [
      libreoffice-bin
    ]
    ++ lib.optionals (!isDarwin) [
      inkscape
      gimp
      libreoffice
    ]
    ++ lib.optionals (hostname == "main") [
      blender
      #darktable - waiting on libsoup to be patched https://github.com/NixOS/nixpkgs/pull/429473
      handbrake
    ]
    ++ lib.optionals (isDarwin || hostname == "main") [
      reaper
    ];
}
