{
  pkgs,
  lib,
  hostname,
  ...
}:

let
  jsonFormat = pkgs.formats.json { };
  gui-settings = import ../../../dot/Mullvad_VPN/gui-settings.nix { inherit hostname; };
in
{
  home.file = {
    # Lynx config
    ".config/lynx/lynx.cfg" = {
      source = ../../../dot/lynx/lynx.cfg;
    };
    ".config/lynx/lynx.lss" = {
      source = ../../../dot/lynx/lynx.lss;
    };

    # Mullvad VPN GUI Config. Deeper settings in configuration.nix
    ".config/Mullvad VPN/gui_settings.json" = lib.mkIf (hostname == "main" || hostname == "media") {
      source = jsonFormat.generate "gui_settings" gui-settings;
    };
  };
}
