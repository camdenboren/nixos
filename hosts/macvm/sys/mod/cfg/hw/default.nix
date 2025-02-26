{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/hw/networking.nix
    ../../../../../../common/sys/mod/cfg/hw/printing.nix

    # Host-specific
    ./audio.nix
    ./boot.nix
    ./hardware-configuration.nix
    #./virtualisation.nix # Only works w/ apple virtualization, currently running qemu
  ];
}
