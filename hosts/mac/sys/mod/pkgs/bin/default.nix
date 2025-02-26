{ inputs, ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/pkgs/bin/utils

    # host-specific
    ./homebrew.nix
    inputs.mac-app-util.darwinModules.default
  ];
}
