{ pkgs, ... }:

{
  home.packages = [
    # Common
    (import ../../../../../../common/usr/scr/dev.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/hello.nix { inherit pkgs; })

    # Host-specific
    (import ../../../scr/replaceConfigs.nix { inherit pkgs; })
  ];
}
