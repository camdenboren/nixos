{ ... }:

{
  imports = [
    # Host-specific
    ./fix-panel.nix
    ./install-plugins.nix
    ./replace-configs.nix

    # Common
    ../../../../../../common/usr/mod/pkgs/srv/utils
  ];
}
