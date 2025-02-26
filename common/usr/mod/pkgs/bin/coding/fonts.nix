{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cantarell-fonts
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;
}
