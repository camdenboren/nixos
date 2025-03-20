{ lib, hostname, ... }:

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
      source = ../../../dot/Mullvad_VPN/gui_settings.json;
    };
  };
}
