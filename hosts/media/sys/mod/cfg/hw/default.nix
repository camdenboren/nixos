{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/hw

    # Host-specific
    ./bluetooth.nix
    ./boot.nix
    ./graphics.nix
    ./hardware-configuration.nix
    ./processor.nix
    ./swap.nix
  ];
}
