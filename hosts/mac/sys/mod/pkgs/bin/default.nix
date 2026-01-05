{ inputs, ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/pkgs/bin/utils

    # host-specific
    ./homebrew.nix
  ];
}
