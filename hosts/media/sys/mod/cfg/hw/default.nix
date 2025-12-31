{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/hw

    # Host-specific
    ./bluetooth.nix
    ./boot.nix
    ./controller.nix
    ./graphics.nix
    ./hardware-configuration.nix
    ./logitech.nix
    ./processor.nix
    ./swap.nix
  ];
}
