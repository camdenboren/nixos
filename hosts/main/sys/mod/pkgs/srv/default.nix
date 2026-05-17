{ ... }:

{
  imports = [
    # Host-specific
    ./invokeai.nix

    # Common
    ../../../../../../common/sys/mod/pkgs/srv/utils
  ];
}
