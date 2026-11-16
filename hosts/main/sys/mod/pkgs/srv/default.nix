{ ... }:

{
  imports = [
    # Host-specific
    ./healthcheck.nix
    ./invokeai.nix

    # Common
    ../../../../../../common/sys/mod/pkgs/srv/utils
  ];
}
