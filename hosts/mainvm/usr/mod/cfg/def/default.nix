{ rice, ... }:

{
  imports = [
    # Common
    ../../../../../../common/usr/mod/cfg/def/gnome.nix
    ../../../../../../common/usr/mod/cfg/def/keybinds.nix
    ../../../../../../common/usr/mod/cfg/def/rice.nix
  ];

  keybinds.enable = true;
  inherit rice;
}
