{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Gaming
    protonup-qt
    protontricks
  ];

  imports = [
    ./mangohud.nix
  ];
}
