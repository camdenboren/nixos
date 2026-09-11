{ pkgs, ... }:

{
  home.packages = [
    # Common
    (import ../../../../../../common/usr/scr/check.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/dev.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/findVPN.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/findVPNDesktop.nix { inherit pkgs; })
    (import ../../../../../../common/usr/scr/hello.nix { inherit pkgs; })
  ];
}
