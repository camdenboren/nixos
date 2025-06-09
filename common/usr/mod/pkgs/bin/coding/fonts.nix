{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (adwaita-fonts.overrideAttrs (old: {
      meta = (old.meta or { }) // {
        platforms = lib.platforms.all;
      };
    }))
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;
}
