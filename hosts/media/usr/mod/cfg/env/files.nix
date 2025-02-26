{ ... }:

{
  home.file = {
    # Set default eq preset for easyeffects
    # in order: Compressor, Pioneer, Bass
    ".config/easyeffects/" = {
      source = ../../../dot/easyeffects;
    };

    # Mullvad VPN GUI Config. Deeper settings in configuration.nix
    ".config/Mullvad VPN/gui_settings.json" = {
      source = ../../../dot/Mullvad_VPN/gui_settings.json;
    };

    # Lynx config
    ".config/lynx/lynx.cfg" = {
      source = ../../../../../../common/usr/dot/lynx/lynx.cfg;
    };
    ".config/lynx/lynx.lss" = {
      source = ../../../../../../common/usr/dot/lynx/lynx.lss;
    };

    # Rygel - media sharing
    ".config/rygel.conf" = {
      source = ../../../dot/rygel/rygel.conf;
    };
  };
}
