{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/hw

    # Host-specific
    ./audio.nix
    ./boot.nix
    ./hardware-configuration.nix
    #./virtualisation.nix # Only works w/ apple virtualization, currently running qemu
  ];
}
