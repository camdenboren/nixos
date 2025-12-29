{ ... }:

{
  imports = [
    # Host-specific
    ./appflowy-cloud.nix
    ./homepage.nix
    ./jellyfin.nix
    ./nginx.nix
    ./open-webui.nix
    ./tailscale.nix
    ./unbound.nix

    # Common
    ../../../../../../common/sys/mod/pkgs/srv/utils
  ];
}
