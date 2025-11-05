{ ... }:

{
  imports = [
    # Host-specific
    ./jellyfin.nix

    # Common
    ../../../../../../common/sys/mod/pkgs/srv/utils
  ];
}
