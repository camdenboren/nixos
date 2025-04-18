{
  pkgs,
  lib,
  hostname,
  system,
  ...
}:

let
  isLinux = lib.hasSuffix "-linux" system;
  isVM = lib.hasSuffix "vm" hostname;
in
{
  home.packages =
    with pkgs;
    lib.optionals (!isVM) [
      mpv
    ]
    ++ lib.optionals (hostname == "main" || hostname == "media") [
      # Basic Apps
      bitwarden
      easyeffects
      freetube
      lollypop
      qbittorrent
      tidal-hifi
      vlc
    ]
    ++ lib.optionals (!isLinux) [
      vlc-bin
    ];

  imports =
    [
      ./librewolf.nix
    ]
    ++ lib.optionals isLinux [
      ./chromium.nix
    ];
}
