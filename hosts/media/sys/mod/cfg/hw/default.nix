{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/hw/networking.nix
    ../../../../../../common/sys/mod/cfg/hw/printing.nix

    # Host-specific
    ./audio.nix
    ./bluetooth.nix
    ./boot.nix
    ./controller.nix
    ./graphics.nix
    ./hardware-configuration.nix
    ./logitech.nix
    ./processor.nix
  ];
}
