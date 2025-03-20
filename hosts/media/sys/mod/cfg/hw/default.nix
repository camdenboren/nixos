{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/hw

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
