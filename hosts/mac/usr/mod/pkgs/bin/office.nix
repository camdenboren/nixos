{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Office
    slack
    zoom-us
  ];
}
