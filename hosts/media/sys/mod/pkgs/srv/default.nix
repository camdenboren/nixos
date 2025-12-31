{ ... }:

{
  imports = [
    # Host-specific
    ./homepage.nix
    ./immich.nix
    ./jellyfin.nix
    ./nginx.nix
    ./open-webui.nix
    ./outline.nix
    ./tailscale.nix
    ./unbound.nix

    # Common
    ../../../../../../common/sys/mod/pkgs/srv/utils
  ];
}
