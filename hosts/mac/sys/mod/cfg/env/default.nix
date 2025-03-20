{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/env

    # Host-specific
    ./activation.nix
    ./platform.nix
    ./sessionVariables.nix
  ];
}
