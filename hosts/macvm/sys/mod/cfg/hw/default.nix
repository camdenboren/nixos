{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/hw

    # Host-specific
    ./hardware-configuration.nix
  ];
}
