{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/hw

    # Host-specific
    ./audio.nix
    ./boot.nix
    ./graphics.nix
    ./hardware-configuration.nix
    ./virtualisation.nix
  ];
}
