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
      bitwarden
      mpv
      yt-x
    ]
    ++ lib.optionals (hostname == "main" || hostname == "media") [
      # Basic Apps
      easyeffects
      high-tide
      lollypop
      qbittorrent
      (tidal-hifi.overrideAttrs {
        desktopItems = [
          (makeDesktopItem {
            exec = "tidal-hifi --disable-gpu";
            name = "TIDAL Hi-Fi";
            desktopName = "tidal-hifi";
            genericName = "TIDAL Hi-Fi";
            comment = "The web version of listen.tidal.com running in electron with hifi support thanks to widevine.";
            icon = "tidal-hifi";
            startupNotify = true;
            terminal = false;
            type = "Application";
            categories = [
              "Network"
              "Application"
              "AudioVideo"
              "Audio"
              "Video"
            ];
            startupWMClass = "tidal-hifi";
            mimeTypes = [ "x-scheme-handler/tidal" ];
            extraConfig.X-PulseAudio-Properties = "media.role=music";
          })
        ];
      })
      vlc
    ]
    ++ lib.optionals (!isLinux) [
      vlc-bin
    ]
    ++ lib.optionals (hostname == "main" || !isLinux) [
      chat-script
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
