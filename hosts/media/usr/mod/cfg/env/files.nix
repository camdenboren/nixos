{ ... }:

{
  home.file = {
    # Set default eq preset for easyeffects
    # in order: Compressor, Pioneer, Bass
    ".config/easyeffects/" = {
      source = ../../../dot/easyeffects;
    };

    # Rygel - media sharing
    ".config/rygel.conf" = {
      source = ../../../dot/rygel/rygel.conf;
    };
  };
}
