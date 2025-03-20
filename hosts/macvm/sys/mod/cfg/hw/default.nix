{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/hw

    # Host-specific
    ./boot.nix
    ./hardware-configuration.nix
    #./virtualisation.nix # Only works w/ apple virtualization, currently running qemu
  ];
}
