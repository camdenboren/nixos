{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/hw

    # Host-specific
    ./boot.nix
    ./hardware-configuration.nix
  ];
}
