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
      high-tide
      lollypop
      readest
      tidal-hifi
      vlc
    ]
    ++ lib.optionals (!isLinux) [
      (lib.hiPrio chatbot-util) # cpython version conflicts w/ chat-script otw
      vlc-bin
    ]
    ++ lib.optionals (hostname == "main" || !isLinux) [
      chat-script
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
