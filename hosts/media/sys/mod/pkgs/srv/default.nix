{ ... }:

{
  imports = [
    # Host-specific
    ./homepage.nix
    ./jellyfin.nix
    ./nginx.nix
    ./open-webui.nix

    # Common
    ../../../../../../common/sys/mod/pkgs/srv/utils
  ];
}
