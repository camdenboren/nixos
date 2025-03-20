{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/hw

    # Host-specific
    ./graphics.nix
    ./hardware-configuration.nix
    ./virtualisation.nix
  ];
}
