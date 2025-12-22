{ ... }:

{
  imports = [
    # Host-specific
    ./homepage.nix
    ./jellyfin.nix
    ./nginx.nix

    # Common
    ../../../../../../common/sys/mod/pkgs/srv/utils
  ];
}
