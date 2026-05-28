{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Office
    slack
    spotify
    #zoom-us - screensharing doesn't work
  ];
}
