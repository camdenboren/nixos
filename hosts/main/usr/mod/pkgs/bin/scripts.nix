{ pkgs, ... }:

{
  home.packages = [
    # Common
    (import ../../../../../../common/usr/scr/dev.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/findVPN.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/findVPNDesktop.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/hello.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/refreshProfiles.nix { inherit pkgs; })

    # Host-specific
    (import ../../../scr/installPlugins.nix { inherit pkgs; })
    (import ../../../scr/refreshPlugins.nix { inherit pkgs; })
    (import ../../../scr/replaceConfigs.nix { inherit pkgs; })
  ];
}
