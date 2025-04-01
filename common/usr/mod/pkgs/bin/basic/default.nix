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
      (freetube.overrideAttrs (old: rec {
        version = "0.23.3";
        src = fetchFromGitHub {
          owner = "FreeTubeApp";
          repo = "FreeTube";
          tag = "v${version}-beta";
          hash = "sha256-EpcYNUtGbEFvetroo1zAyfKxW70vD1Lk0aJKWcaV39I=";
        };

        yarnOfflineCache = fetchYarnDeps {
          yarnLock = "${src}/yarn.lock";
          hash = "sha256-xiJGzvmfrvvB6/rdwALOxhWSWAZ31cbySYygtG8+QpQ=";
        };
      }))
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
