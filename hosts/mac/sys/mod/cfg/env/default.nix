{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/env

    # Host-specific
    ./platform.nix
    ./sessionVariables.nix
  ];
}
