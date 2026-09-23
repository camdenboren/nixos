{ pkgs, hostname, ... }:

{
  home.packages = [
    # Common
    (import ../../../../../../common/usr/scr/audioPreventsLock.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/check.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/dev.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/findVPN.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/findVPNDesktop.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/hello.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/upsMetrics.nix { inherit pkgs hostname; })

    # Host-specific
    (import ../../../scr/installPlugins.nix { inherit pkgs; })
    (import ../../../scr/replaceConfigs.nix { inherit pkgs; })
  ];
}
