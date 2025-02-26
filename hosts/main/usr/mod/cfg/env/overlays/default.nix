{ ... }:

{
  imports = [
    # Common
    ../../../../../../../common/usr/mod/cfg/env/overlays/firefox-addons.nix

    # Host-specific
    ./plugins.nix
  ];
}
