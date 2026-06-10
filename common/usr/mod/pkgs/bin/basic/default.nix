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
      alc-calc
      # bitwarden-desktop # using homebrew version since compiler-rt-libc fix hasn't yet landed in nixpkgs
      mpv
      yt-x
    ]
    ++ lib.optionals (hostname == "main" || hostname == "media") [
      # Basic Apps
      bitwarden-desktop
      lollypop
      readest
      vlc
    ]
    ++ lib.optionals (!isLinux) [
      vlc-bin
    ]
    ++ lib.optionals (hostname == "media") [
      jellyfin-ffmpeg
      qbittorrent
    ];

  imports = [
    ./librewolf.nix
  ]
  ++ lib.optionals isLinux [
    ./chromium.nix
  ]
  ++ lib.optionals (!isVM) [
    ./freetube.nix
  ]
  ++ lib.optionals (!isVM || !isLinux) [
    ../../../cfg/env/overlays/personal.nix
  ];
}
