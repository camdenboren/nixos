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
      bitwarden-desktop
      mpv
      yt-x
    ]
    ++ lib.optionals (hostname == "main" || hostname == "media") [
      # Basic Apps
      lollypop
      readest
      vlc
    ]
    ++ lib.optionals (!isLinux) [
      chatbot-util
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
  ];
}
