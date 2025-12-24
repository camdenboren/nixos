{ ... }:

{
  imports = [
    # Host-specific
    ./comfyui.nix

    # Common
    ../../../../../../common/sys/mod/pkgs/srv/utils
  ];
}
