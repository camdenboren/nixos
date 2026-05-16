{ ... }:

# generate penpot drv after cd'ing here via
# $(curl -o docker-compose.yml https://raw.githubusercontent.com/penpot/penpot/refs/heads/develop/docker/images/docker-compose.yaml && nix run github:aksiksi/compose2nix -- -project=penpot && mv docker-compose.nix penpot.nix && tr docker-compose.yml && fmt)

{
  imports = [
    # Host-specific
    ./actual.nix
    ./homebox.nix
    ./homepage.nix
    ./immich.nix
    ./jellyfin.nix
    ./lubelogger.nix
    ./nginx.nix
    ./open-webui.nix
    ./outline.nix
    ./penpot.nix
    ./tailscale.nix
    ./unbound.nix
    ./ups.nix

    # Common
    ../../../../../../common/sys/mod/pkgs/srv/utils
  ];
}
