{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/usr/mod/cfg/env

    # Host-specific
    ./files.nix
    ./sessionVariables.nix
  ];
}
