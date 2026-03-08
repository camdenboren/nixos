{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/usr/mod/cfg/env

    # Host-specific
    ./activation.nix
    ./files.nix
    ./sessionVariables.nix
  ];
}
