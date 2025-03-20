{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/hw

    # Host-specific
    ./boot.nix
    ./graphics.nix
    ./hardware-configuration.nix
    ./virtualisation.nix
  ];
}
