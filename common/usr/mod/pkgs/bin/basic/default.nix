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
        version = "0.23.4";
        src = fetchFromGitHub {
          owner = "FreeTubeApp";
          repo = "FreeTube";
          tag = "v${version}-beta";
          hash = "sha256-JQob4NyZ00iOnRbSyNWjL4xyNQ14ixyZDXsJ7KBd9ZM=";
        };
        yarnOfflineCache = fetchYarnDeps {
          yarnLock = "${src}/yarn.lock";
          hash = "sha256-F1YcdshWGRCO7kHsCK0Ejs0aMR7BFXd5M9ITdRVcpbk=";
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
