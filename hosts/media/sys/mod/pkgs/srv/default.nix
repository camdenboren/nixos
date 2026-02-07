{ ... }:

# generate penpot drv after cd'ing here via
# $(curl -o docker-compose.yml https://raw.githubusercontent.com/penpot/penpot/refs/heads/develop/docker/images/docker-compose.yaml && nix run github:aksiksi/compose2nix -- -project=penpot && mv docker-compose.nix penpot.nix && tr docker-compose.yml && fmt)
#
# update via
#
# shell jq
#
# sudo podman pull $(sudo podman inspect penpot-penpot-postgres | jq -r .[0].ImageName)
# sudo podman pull $(sudo podman inspect penpot-penpot-mailcatch | jq -r .[0].ImageName)
# sudo podman pull $(sudo podman inspect penpot-penpot-valkey | jq -r .[0].ImageName)
# sudo podman pull $(sudo podman inspect penpot-penpot-exporter | jq -r .[0].ImageName)
# sudo podman pull $(sudo podman inspect penpot-penpot-backend | jq -r .[0].ImageName)
# sudo podman pull $(sudo podman inspect penpot-penpot-frontend | jq -r .[0].ImageName)
#
# sudo systemctl restart podman-penpot-penpot-postgres.service
# sudo systemctl restart podman-penpot-penpot-mailcatch.service
# sudo systemctl restart podman-penpot-penpot-valkey.service
# sudo systemctl restart podman-penpot-penpot-exporter.service
# sudo systemctl restart podman-penpot-penpot-backend.service
# sudo systemctl restart podman-penpot-penpot-frontend.service

{
  imports = [
    # Host-specific
    ./homebox.nix
    ./homepage.nix
    ./immich.nix
    ./jellyfin.nix
    ./nginx.nix
    ./open-webui.nix
    ./outline.nix
    ./penpot.nix
    ./tailscale.nix
    ./unbound.nix

    # Common
    ../../../../../../common/sys/mod/pkgs/srv/utils
  ];
}
