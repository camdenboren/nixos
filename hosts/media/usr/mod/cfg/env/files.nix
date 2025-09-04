{ ... }:

{
  home.file = {
    # Rygel - media sharing
    ".config/rygel.conf" = {
      source = ../../../dot/rygel/rygel.conf;
    };
  };
}
