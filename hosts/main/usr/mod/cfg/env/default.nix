{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/usr/mod/cfg/env/home-manager.nix
    ../../../../../../common/usr/mod/cfg/env/nix-settings.nix
    ../../../../../../common/usr/mod/cfg/env/sessionVariables.nix
    ../../../../../../common/usr/mod/cfg/env/xdg.nix

    # Host-specific
    ./activation.nix
    ./files.nix
    ./overlays
  ];
}
